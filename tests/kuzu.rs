use cucumber::{World, gherkin::Step, given, then, when};
use kuzu::{Connection, Database, Error, QueryResult, SystemConfig};
use std::collections::{HashMap, HashSet};
use std::ops::Sub;

const OUTPUT_SEP: &str = " | ";

#[derive(Debug, World)]
#[world(init = Self::new)]
pub struct Kuzu {
    db: Database,
    error: Option<String>,
    columns: String,
    results: HashMap<String, u32>,
    expected_state: String,
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
            expected_state: String::new(),
        }
    }

    fn execute_query(&self, query: &str) -> Result<QueryResult, Error> {
        let conn = Connection::new(&self.db).expect("Failed to connect to DB");
        conn.query(query)
    }

    fn get_state(&self) -> String {
        let mut res = self
            .execute_query("MATCH (n)-[e]->() RETURN count(n), count(e)")
            .expect("Failed to execute query");
        let out = res.next().expect("Node count missing");
        format!("{} | {}", out[0], out[1])
    }
}

#[given(regex = r"^an empty graph|any graph$")]
fn empty_graph(kuzu: &mut Kuzu) {
    kuzu.expected_state = kuzu.get_state();
}

#[given(expr = "having defined kuzu types: {word}")]
fn pre_create_types(kuzu: &mut Kuzu, id: String) {
    let query = match id.as_str() {
        "a:l" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE REL TABLE LOOP(FROM A to A);
            "
        }
        "a_label:w_year" => {
            "
              CREATE NODE TABLE Artist(id SERIAL PRIMARY KEY, label STRING);
              CREATE REL TABLE WORKED_WITH(FROM Artist to Artist, year INT64);
            "
        }
        "ab" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
            "
        }
        "ab:bf" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE REL TABLE BAR(FROM B to B);
              CREATE REL TABLE FOO(FROM A to B);
            "
        }
        "ab_num:k" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE REL TABLE KNOWS(FROM A to B);
            "
        }
        "ab_name:k" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE KNOWS(FROM A to B);
            "
        }
        "ab_num:l" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE REL TABLE LOOP(FROM A to B);
            "
        }
        "ab_num:r" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE REL TABLE REL(FROM A to B, name STRING);
            "
        }
        "ab:t" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM A to B);
            "
        }
        "ab_name:t" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE T(FROM A to B);
            "
        }
        "ab:t12" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T1(FROM A to B);
              CREATE REL TABLE T2(FROM B to A);
            "
        }
        "ab:t14" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T1(FROM A to B);
              CREATE REL TABLE T2(FROM B to A);
              CREATE REL TABLE T3(FROM B to B);
              CREATE REL TABLE T4(FROM A to A);
            "
        }
        "abc_name" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
            "
        }
        "abc_num:k" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, num INT64);
              CREATE REL TABLE KNOWS(FROM A to B, FROM A to C);
            "
        }
        "abc_name:k" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE KNOWS(FROM A to B, FROM B to C);
            "
        }
        "abc_name:k_num" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE KNOWS(FROM A to B, FROM B to C, num INT64);
            "
        }
        "abc_name:kf" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE KNOWS(FROM A to B);
              CREATE REL TABLE FRIEND(FROM B to C);
            "
        }
        "abc:t" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM A to B, FROM A to C);
            "
        }
        "abc_name:t" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE T(FROM B to A, FROM C TO B);
            "
        }
        "abc:y" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY);
              CREATE REL TABLE Y(FROM A to B, FROM B TO C);
            "
        }
        "abc_num:fk" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, num INT64);
              CREATE REL TABLE KNOWS(FROM A to B);
              CREATE REL TABLE FRIEND(FROM B to C);
            "
        }
        "abc_num:r_name" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, num INT64);
              CREATE REL TABLE REL(FROM A to B, FROM B TO C, name STRING);
            "
        }
        "abl:t12l" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Looper(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T1(FROM A to Looper);
              CREATE REL TABLE T2(FROM Looper to B);
              CREATE REL TABLE LOOP(FROM Looper to Looper);
            "
        }
        "abx:k_name" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE X(id SERIAL PRIMARY KEY);
              CREATE REL TABLE KNOWS(FROM X to A, FROM X to B, name STRING);
            "
        }
        "abcd_name:l" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE D(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE LIKES(FROM A to B, FROM B TO C, FROM C TO D);
            "
        }
        "abcd_name:t" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE D(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE T(FROM B to A, FROM C TO B, FROM D TO C);
            "
        }
        "abce_name:l" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE D(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE E(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE LIKES(FROM A to B, FROM B to A, FROM B TO C, FROM C TO D, FROM D TO E);
            "
        }
        "abcs:lr" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE Singlee(id SERIAL PRIMARY KEY);
              CREATE REL TABLE LOOP(FROM B to B);
              CREATE REL TABLE REL(FROM Singlee to A, FROM Singlee to B, FROM A TO C);
            "
        }
        "abcs:lrx" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE Singlee(id SERIAL PRIMARY KEY);
              CREATE REL TABLE LOOP(FROM B to B);
              CREATE REL TABLE REL(FROM Singlee to A, FROM Singlee to B, FROM A TO C);
              CREATE REL TABLE X(FROM A to B);
            "
        }
        "abcns_num:lr" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE Singlee(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE NonExistent(id SERIAL PRIMARY KEY);
              CREATE REL TABLE LOOP(FROM B to B);
              CREATE REL TABLE REL(FROM Singlee to A, FROM Singlee to B, FROM A TO C);
            "
        }
        "abcns_num:lnr" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE NotThere(id SERIAL PRIMARY KEY, num INT64);
              CREATE NODE TABLE Singlee(id SERIAL PRIMARY KEY);
              CREATE REL TABLE LOOP(FROM B to B);
              CREATE REL TABLE NOR_THIS(FROM NotThere to NotThere);
              CREATE REL TABLE REL(FROM Singlee to A, FROM Singlee to B, FROM A TO C);
            "
        }
        "abe:r_num" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Endd(id SERIAL PRIMARY KEY);
              CREATE REL TABLE REL(FROM A to B, FROM B TO Endd, num INT64);
            "
        }
        "an:xy" => {
            "
              CREATE NODE TABLE A(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE REL TABLE X(FROM A to N);
              CREATE REL TABLE Y(FROM N to N);
            "
        }
        "bce:r_num" => {
            "
              CREATE NODE TABLE B(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE C(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Start(id SERIAL PRIMARY KEY);
              CREATE REL TABLE REL(FROM Start to B, FROM B TO C, num INT64);
            "
        }
        "bgry:t" => {
            "
              CREATE NODE TABLE Blue(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Green(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Red(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Yellow(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM Blue TO Red, FROM Red TO Green, FROM Red TO Yellow);
            "
        }
        "ens_name:c" => {
            "
              CREATE NODE TABLE Eend(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE Start(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE CONNECTED_TO(FROM N to Start, FROM N to Eend, FROM N to N);
            "
        }
        "l12_name:t" => {
            "
              CREATE NODE TABLE Label1(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE Label2(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE TYPE(FROM Label2 to Label1);
            "
        }
        "l13_name:t12" => {
            "
              CREATE NODE TABLE Label1(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE Label2(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE Label3(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE T1(FROM Label2 to Label1);
              CREATE REL TABLE T2(FROM Label2 to Label3);
            "
        }
        "mn_name:t" => {
            "
              CREATE NODE TABLE Movie(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE T(FROM N to Movie);
            "
        }
        "n_name" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
            "
        }
        "n_num" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, num INT64);
            "
        }
        "n_name:c" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE CONTAINS(FROM N to N);
            "
        }
        "n_name:x" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE X(FROM N to N);
            "
        }
        "n:e" => {
            "
              CREATE NODE TABLE Node(id SERIAL PRIMARY KEY);
              CREATE REL TABLE Edge(FROM Node to Node);
            "
        }
        "n_name:k" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE KNOWS(FROM N to N);
            "
        }
        "n:n" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE REL TABLE NOT_EXIST(FROM N to N);
            "
        }
        "n:t" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM N to N);
            "
        }
        "n_name:t" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE T(FROM N to N);
            "
        }
        "n_var:t" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, var STRING);
              CREATE REL TABLE T(FROM N to N);
            "
        }
        "n_name:ab" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE A(FROM N to N);
              CREATE REL TABLE B(FROM N to N);
            "
        }
        "n_name:cf" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE CONTAINS(FROM N to N);
              CREATE REL TABLE FRIEND(FROM N to N);
            "
        }
        "n_name:hkw" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY, name STRING);
              CREATE REL TABLE KNOWS(FROM N to N);
              CREATE REL TABLE HATES(FROM N to N);
              CREATE REL TABLE WONDERS(FROM N to N);
            "
        }
        "nf:t" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Foo(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM N to Foo, FROM N to N);
            "
        }
        "nt:t" => {
            "
              CREATE NODE TABLE N(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE TheLabel(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM N to N);
            "
        }
        "pf:a" => {
            "
              CREATE NODE TABLE P(id SERIAL PRIMARY KEY, name STRING);
              CREATE NODE TABLE F(id SERIAL PRIMARY KEY, type STRING);
              CREATE REL TABLE ATE(FROM P to F, times INT64);
            "
        }
        "pt:ps" => {
            "
              CREATE NODE TABLE Player(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Team(id SERIAL PRIMARY KEY);
              CREATE REL TABLE PLAYS_FOR(FROM Player to Team);
              CREATE REL TABLE SUPPORTS(FROM Player to Team);
            "
        }
        "x:t" => {
            "
              CREATE NODE TABLE X(id SERIAL PRIMARY KEY);
              CREATE REL TABLE T(FROM X to X);
            "
        }
        "xyy:r" => {
            "
              CREATE NODE TABLE X(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE Y(id SERIAL PRIMARY KEY);
              CREATE NODE TABLE YZ(id SERIAL PRIMARY KEY);
              CREATE REL TABLE REL(FROM X to Y, FROM X TO YZ);
            "
        }
        _ => panic!("Query not found: {id}"),
    };
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

#[when("executing query:")]
fn execute_query(kuzu: &mut Kuzu, step: &Step) {
    let res = kuzu.execute_query(step.docstring.as_ref().expect("Query missing").as_str());
    match res {
        Ok(res) => {
            kuzu.columns = res.get_column_names().join(OUTPUT_SEP);
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
fn compare_results(kuzu: &mut Kuzu, step: &Step) {
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
            "Found result not expected: {result} || {expected_results:?} || {:?} || {}",
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

#[then("no side effects")]
fn check_side_effects(kuzu: &mut Kuzu) {
    let found = kuzu.get_state();
    assert_eq!(kuzu.expected_state, found);
}

#[then(expr = "a SyntaxError should be raised at compile time: {word}")]
fn check_error(kuzu: &mut Kuzu, error: String) {
    let found_error = kuzu.error.as_ref().expect("SyntaxError expected");
    match error.as_str() {
        "InvalidParameterUse" | "InvalidRelationshipPattern" => {
            assert!(found_error.contains("Parser exception"), "{found_error}");
        }
        "VariableTypeConflict" | "RelationshipUniquenessViolation" => {
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
