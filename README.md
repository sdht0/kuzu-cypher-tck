# Kuzu Cypher TCK tests

Testing Kuzu's conformance to openCypher using their [TCK](https://github.com/opencypher/openCypher/tree/main/tck).

## Prepare

Use pre-built shared lib for faster compilation.

```bash
mkdir kuzu-lib
cd kuzu-lib
curl -L -O https://github.com/kuzudb/kuzu/releases/download/v0.9.0/libkuzu-linux-aarch64.tar.gz
tar xzf libkuzu-linux-aarch64.tar.gz
rm libkuzu-linux-aarch64.tar.gz
cd ..
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$PWD/kuzu-lib"
```

Disable by removing `[env]` from `.cargo/config.toml`.

## Run

All tests:

```bash
cargo test --test kuzu -- -t 'not @fails'
```

Filter by file:

```bash
cargo test --test kuzu -- -t 'not @fails' -i 'tests/**/Match1*'
```
