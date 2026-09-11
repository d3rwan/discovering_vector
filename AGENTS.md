# AGENTS.md — discovering_vector

Learning/demo pipeline for Vector.dev (v0.8.0): ship nginx logs → Kafka → Vector parsing → Elasticsearch → Kibana.

## Architecture

`docker-compose.yml` services (pinned old versions — do not bump casually):

- `webapp` (build `./webapp/`, nginx + joli-admin demo + embedded `vector:0.8.0`) — tails `/var/log/nginx/*.log`, sinks JSON to Kafka topic `events`
- `vector` (`timberio/vector:0.8.0-alpine`, config `vector.toml`) — source `kafka` topic `events` → `json_parser` → `grok_parser` (nginx access-log pattern) → sink `elasticsearch`
- `kafka` + `zookeeper` (confluent 5.4.0), `rest-proxy`, `kafka-topics-ui` (:18000)
- `elasticsearch` 7.6.2 (:9200), `kibana` 7.6.2 (:5601)

Key files:

- `vector.toml` — main pipeline (kafka source, json + grok transforms, ES sink, embedded `[[tests]]`)
- `webapp/vector.toml` — edge agent config (file source → kafka sink)
- `webapp/Dockerfile`, `webapp/start.sh` — nginx + vector startup, log tailing

## Commands

```bash
docker-compose up --build    # full stack
docker-compose up vector     # vector only (needs kafka + elasticsearch up)
docker-compose ps / logs vector
```

Validate the main pipeline (Vector 0.8 built-in unit tests defined in `[[tests]]`):

```bash
vector test vector.toml      # or: docker run --rm -v $PWD/vector.toml:/etc/vector/vector.toml timberio/vector:0.8.0-alpine test /etc/vector/vector.toml
vector validate vector.toml  # config syntax check
```

## Conventions for agents

- This is a static demo repo: no app code, no package manager, no test suite besides `[[tests]]` in `vector.toml`.
- Keep the grok pattern, field names (`client`, `user`, `timestamp`, `verb`, `path`, `status`, `bytes`, `referer`, `user_agent`) and typed coercions (`status`/`bytes` int, `timestamp` `%d/%b/%Y:%H:%M:%S %z`) in sync with the test log line when editing transforms.
- `vector.toml` uses TOML, not the later YAML/CUE Vector syntax — do not migrate formats.
- Service hostnames inside compose network are `kafka:29092`, `elasticsearch:9200`; `localhost:9092` / `:9200` / `:5601` / `:18000` are host-side ports only.
- `$PWD` volume mount in compose requires running from repo root.
