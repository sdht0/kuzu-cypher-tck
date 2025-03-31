use cucumber::{World, gherkin::Step, given, then, when};
use kuzu::{Connection, Database, Error, QueryResult, SystemConfig, Value};
use std::collections::{HashMap, HashSet};
use std::ops::Sub;

mod tables;

const OUTPUT_SEP: &str = " | ";

#[derive(Debug, World)]
#[world(init = Self::new)]
pub struct Kuzu {
    db: Database,
    error: Option<String>,
    columns: String,
    results: HashMap<String, u32>,
    expected_state: (usize, usize),
}

impl Kuzu {
    fn new() -> Kuzu {
        Kuzu {
            db: Database::in_memory(
                SystemConfig::default()
                    .max_num_threads(1)
                    .buffer_pool_size(128 * 1024 * 1024)
                    .max_db_size(512 * 1024 * 1024),
            )
            .expect("Could not create database"),
            error: None,
            columns: String::new(),
            results: HashMap::new(),
            expected_state: (0, 0),
        }
    }

    fn execute_query(&self, query: &str) -> Result<QueryResult, Error> {
        let conn = Connection::new(&self.db).expect("Failed to connect to DB");
        conn.query(query)
    }

    fn get_state(&self) -> (usize, usize) {
        let mut res = self
            .execute_query("MATCH (n) RETURN count(n)")
            .expect("Failed to execute query");
        let out = res.next().expect("Node count missing");
        let nodes = match &out[0] {
            Value::Int64(c) => usize::try_from(*c).unwrap(),
            _ => panic!("Cannot parse counts from: {out:?}"),
        };
        let mut res = self
            .execute_query("MATCH ()-[r]->() RETURN count(r)")
            .expect("Failed to execute query");
        let out = res.next().expect("Edge count missing");
        let edges = match &out[0] {
            Value::Int64(c) => usize::try_from(*c).unwrap(),
            _ => panic!("Cannot parse counts from: {out:?}"),
        };
        (nodes, edges)
    }
}

#[given(regex = r"^an empty graph|any graph$")]
fn empty_graph(kuzu: &mut Kuzu) {
    kuzu.expected_state = kuzu.get_state();
}

#[given(expr = "having defined kuzu types: {word}")]
fn pre_create_types(kuzu: &mut Kuzu, id: String) {
    let query = crate::tables::get_table(id.as_str());
    let _ = kuzu.execute_query(query).expect("Failed to execute query");
    kuzu.expected_state = kuzu.get_state();
}

#[given("having executed:")]
fn pre_execute_query(kuzu: &mut Kuzu, step: &Step) {
    let _ = kuzu
        .execute_query(step.docstring.as_ref().expect("Query missing").as_str())
        .expect("Failed to execute query");
    kuzu.expected_state = kuzu.get_state();
}

#[when(regex = r"^executing( control)? query:")]
fn execute_query(kuzu: &mut Kuzu, step: &Step) {
    let res = kuzu.execute_query(step.docstring.as_ref().expect("Query missing").as_str());
    match res {
        Ok(res) => {
            kuzu.columns = res.get_column_names().join(OUTPUT_SEP);
            kuzu.results.clear();
            for r in res {
                let out = r
                    .iter()
                    .map(std::string::ToString::to_string)
                    .collect::<Vec<_>>()
                    .join(OUTPUT_SEP);
                *kuzu.results.entry(out).or_insert(0) += 1;
            }
        }
        Err(e) => {
            kuzu.error = Some(format!("{e:?}"));
        }
    }
}

#[then(
    regex = r"^the result should be, in any order:|the result should be \(ignoring element order for lists\):$"
)]
fn check_results(kuzu: &mut Kuzu, step: &Step) {
    if let Some(error) = &kuzu.error {
        panic!("Expected success but ran into error: {error}");
    }
    let table = step.table.as_ref().expect("Table missing");
    let mut iter = table.rows.iter();
    let header = iter.next().expect("Header missing");
    let expected_columns = header.join(OUTPUT_SEP);
    let mut expected_results = HashMap::new();
    for row in iter {
        *expected_results
            .entry(row.join(OUTPUT_SEP))
            .or_insert(0_u32) += 1;
    }
    assert_eq!(expected_columns, kuzu.columns, "Columns don't match");
    for (result, count) in &kuzu.results {
        assert!(
            expected_results.contains_key(result),
            "Found result not expected: {result} || {expected_results:?} || {:?} || {:?}",
            kuzu.results,
            kuzu.get_state()
        );
        let expected_count = expected_results.get(result).expect("Result missing");
        assert_eq!(
            expected_count, count,
            "Expected counts didn't match: {result} || {expected_results:?} || {:?}",
            kuzu.results
        );
    }
    assert_eq!(
        expected_results.len(),
        kuzu.results.len(),
        "Expected results missing: {:?}",
        expected_results
            .keys()
            .collect::<HashSet<&String>>()
            .sub(&kuzu.results.keys().collect::<HashSet<&String>>())
    );
}

#[then("the result should be empty")]
fn check_empty_result(kuzu: &mut Kuzu) {
    if let Some(error) = &kuzu.error {
        panic!("Expected success but ran into error: {error}");
    }
    assert!(
        kuzu.results.is_empty(),
        "Expected empty results but found: {:?}",
        kuzu.results
    );
}

#[then("no side effects")]
fn check_no_side_effects(kuzu: &mut Kuzu) {
    let found = kuzu.get_state();
    assert_eq!(kuzu.expected_state, found);
}

#[then("the side effects should be:")]
fn check_side_effects(kuzu: &mut Kuzu, step: &Step) {
    if let Some(error) = &kuzu.error {
        panic!("Expected success but ran into error: {error}");
    }
    let mut expected_state = kuzu.expected_state;
    let table = step.table.as_ref().expect("Table missing");
    for entry in table.rows.iter() {
        let change = entry[1].parse::<usize>().unwrap();
        match entry[0].as_str() {
            "+nodes" => expected_state.0 += change,
            "-nodes" => expected_state.0 -= change,
            "+relationships" => expected_state.1 += change,
            "-relationships" => expected_state.1 -= change,
            "+properties" | "-properties" | "+labels" | "-labels" => {}
            _ => panic!("Unexpected entry type: {entry:?}"),
        }
    }
    let found = kuzu.get_state();
    assert_eq!(expected_state, found);
}

#[then(expr = "a SyntaxError should be raised at compile time: {word}")]
fn check_error(kuzu: &mut Kuzu, error: String) {
    let found_error = kuzu.error.as_ref().expect("SyntaxError expected");
    match error.as_str() {
        "InvalidParameterUse" | "InvalidRelationshipPattern" => {
            assert!(found_error.contains("Parser exception"), "{found_error}");
        }
        "VariableTypeConflict"
        | "RelationshipUniquenessViolation"
        | "VariableAlreadyBound"
        | "UndefinedVariable" => {
            assert!(found_error.contains("Binder exception"), "{found_error}");
        }
        _ => panic!("Unknown error: {error}, found {found_error}"),
    }
}

fn main() {
    futures::executor::block_on(
        Kuzu::cucumber()
            .fail_on_skipped()
            .run("tests/features/clauses"),
    );
}
