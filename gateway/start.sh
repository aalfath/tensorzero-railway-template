#!/bin/bash
# Railway start script for the TensorZero Gateway.
# 1. waits for Postgres and applies TensorZero's Postgres migrations,
# 2. stores the generated admin API key (TENSORZERO_ADMIN_API_KEY),
# 3. loads optional extra config from TENSORZERO_CONFIG_TOML,
# 4. execs the gateway. Any failure exits non-zero so Railway restarts it.
set -euo pipefail

: "${TENSORZERO_POSTGRES_URL:?TENSORZERO_POSTGRES_URL must be set (reference to the Postgres service)}"
export TENSORZERO_GATEWAY_BIND_ADDRESS="${TENSORZERO_GATEWAY_BIND_ADDRESS:-[::]:${PORT:-3000}}"

# Railway keeps optional variables as empty strings; drop empty provider keys so
# the gateway treats them as unset.
for v in $(compgen -e); do
  case "$v" in *_API_KEY|*_API_KEY_ID|AWS_*|AZURE_*) [ -z "${!v}" ] && unset "$v" ;; esac
done

# 1. Migrations (sqlx takes an advisory lock, so overlapping deploys are safe).
ok=0
for i in $(seq 1 60); do
  if gateway --run-postgres-migrations; then ok=1; break; fi
  echo "start.sh: Postgres migrations failed (try $i/60), retrying in 3 s" >&2
  sleep 3
done
[ "$ok" = 1 ] || { echo "start.sh: giving up on Postgres migrations" >&2; exit 1; }

# 2. Admin API key: sk-t0-<12-char public id>-<48-char secret>.
if [ -n "${TENSORZERO_ADMIN_API_KEY:-}" ]; then
  IFS=- read -r sk t0 pub long rest <<<"$TENSORZERO_ADMIN_API_KEY"
  if [ "$sk" != sk ] || [ "$t0" != t0 ] || [ -n "${rest:-}" ] \
     || ! [[ "$pub" =~ ^[A-Za-z0-9]{12}$ ]] || ! [[ "$long" =~ ^[A-Za-z0-9]{48}$ ]]; then
    echo "start.sh: TENSORZERO_ADMIN_API_KEY must look like sk-t0-<12 letters/digits>-<48 letters/digits>" >&2
    exit 1
  fi
  hash=$(printf '%s' "$long" | sha256sum | cut -d' ' -f1)
  # Insert once; a key you later disable in the UI stays disabled.
  psql "$TENSORZERO_POSTGRES_URL" -v ON_ERROR_STOP=1 -q -v pub="$pub" -v hash="$hash" <<'SQL'
INSERT INTO tensorzero_auth_api_key (organization, workspace, description, public_id, hash)
VALUES ('default', 'default', 'Railway admin key (TENSORZERO_ADMIN_API_KEY)', :'pub', :'hash')
ON CONFLICT (public_id) DO NOTHING;
SQL
  echo "start.sh: admin API key ${pub} is registered"
fi

# 3. Optional extra configuration.
rm -f /app/config/custom/*.toml
if [ -n "${TENSORZERO_CONFIG_TOML:-}" ]; then
  printf '%s\n' "$TENSORZERO_CONFIG_TOML" > /app/config/custom/custom.toml
  echo "start.sh: loaded extra config from TENSORZERO_CONFIG_TOML"
fi

# 4. Gateway.
exec gateway --config-file '/app/config/**/*.toml' --log-format "${TENSORZERO_LOG_FORMAT:-pretty}" "$@"
