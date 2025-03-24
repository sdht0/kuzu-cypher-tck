# Kuzu Cypher TCK tests

Testing Kuzu's conformance to openCypher using their [TCK](https://github.com/opencypher/openCypher/tree/main/tck).

## Run

All tests:
```bash
cargo test --test kuzu -- -t 'not @fails'
```

Filter by file:
```bash
cargo test --test kuzu -- -t 'not @fails' -i Match2\*
```
