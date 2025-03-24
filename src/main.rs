use kuzu::{Connection, Database, SystemConfig};

fn main() {
    let db = Database::in_memory(
        SystemConfig::default()
            .max_num_threads(1)
            .buffer_pool_size(128 * 1024 * 1024)
            .max_db_size(512 * 1024 * 1024),
    )
    .expect("Could not create database");
    let query = [
        "CREATE NODE TABLE A(id SERIAL PRIMARY KEY, num INT64);
        CREATE NODE TABLE B(id SERIAL PRIMARY KEY, num INT64);
        CREATE NODE TABLE C(id SERIAL PRIMARY KEY, num INT64);
        CREATE NODE TABLE Singlee(id SERIAL PRIMARY KEY);
        CREATE REL TABLE REL(FROM Singlee to A, FROM Singlee to B, FROM A TO C);
        CREATE REL TABLE LOOP(FROM B to B);
        CREATE REL TABLE X(FROM A to B);",
        "CREATE (s:Singlee), (a:A {num: 42}),
        (b:B {num: 46}), (c:C);
        CREATE (s)-[:REL]->(a),
        (s)-[:REL]->(b),
        (a)-[:REL]->(c),
        (b)-[:LOOP]->(b);",
        "MATCH (a:A), (b:B)
        OPTIONAL MATCH p = (a)-[:X]->(b)
        RETURN p;",
    ];
    for q in query {
        execute_query(&db, q);
    }
}

fn execute_query(db: &Database, query: &str) {
    let conn = Connection::new(db).expect("Failed to connect to DB");
    let mut res = conn.query(query).expect("Failed to execute query");
    println!("{:?}", res.display());
}
