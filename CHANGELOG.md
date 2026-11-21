# Changelog

Every change merged to `main` reaches people who deployed this template as an
"update available" notice in Railway. Breaking changes are listed first.

## 2026.6.0 (2026-11-21)

- First release of the Railway template.
- TensorZero Gateway `tensorzero/gateway:2026.6.0`, TensorZero UI `tensorzero/ui:2026.6.0`,
  Postgres `tensorzero/postgres:17.9` (Postgres 17.9 with pg_cron and pgvector), all pinned by digest.
- Gateway auth is on; an admin API key is generated at deploy time and registered on first start.
- Postgres migrations run in the Gateway's start script on every start.
