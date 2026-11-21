[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/tensorzero?utm_medium=integration&utm_source=button&utm_campaign=tensorzero)

# TensorZero on Railway

TensorZero is an open-source LLMOps platform. Its gateway gives your apps one OpenAI-compatible API for OpenAI, Anthropic and about 20 other model providers. It stores every inference and feedback signal, and its web UI lets you browse that data, build datasets, run evaluations and fine-tuning jobs, and manage API keys.

## About Hosting TensorZero

Hosting TensorZero means running three parts together: the TensorZero Gateway (a Rust service on port 3000 that your apps call), the TensorZero UI (a Node web app on port 4000), and a Postgres database with the pg_cron and pgvector extensions, where the gateway keeps inferences, feedback and API keys. The gateway's Postgres migrations don't run on their own, the UI has no login of its own, and every client needs a gateway API key. This template wires the three services over Railway's private network, keeps Postgres on a volume, runs the migrations on every gateway start, turns gateway authentication on and creates an admin API key for you.

## Common Use Cases

* One OpenAI-compatible endpoint for many LLM providers, with per-app API keys you can disable
* Logging every prompt, response, latency and token count, and browsing them in a web UI
* Running evaluations, A/B tests between prompts or models, and building fine-tuning datasets from production data

## Dependencies for TensorZero Hosting

* TensorZero Gateway and UI 2026.6.0 (official `tensorzero/gateway` and `tensorzero/ui` images)
* Postgres 17.9 with pg_cron and pgvector (TensorZero's `tensorzero/postgres` image)
* An API key for at least one model provider (OpenAI, Anthropic or any other TensorZero supports)

### Deployment Dependencies

* [TensorZero documentation](https://www.tensorzero.com/docs)
* [TensorZero 2026.6.0 release](https://github.com/tensorzero/tensorzero/releases/tag/2026.6.0)
* [Template repository](https://github.com/aalfath/tensorzero-railway-template)

### Implementation Details

The template deploys three services, all built from [aalfath/tensorzero-railway-template](https://github.com/aalfath/tensorzero-railway-template):

* **Postgres**: Postgres 17.9 with pg_cron and pgvector, data on a volume, password generated at deploy time.
* **Gateway** (public): starts after Postgres, applies TensorZero's Postgres migrations, registers the admin API key and serves the API. Health check: `/health`.
* **UI** (public): the TensorZero web UI. It talks to the gateway over the private network. Health check: `/health`.

After deploy:

1. Open the Gateway service's **Variables** tab and copy `TENSORZERO_ADMIN_API_KEY` (it looks like `sk-t0-…`).
2. Open the UI's public URL. Pages ask for an API key: paste the admin key. The browser keeps it in a cookie. The UI holds no key of its own, so nobody can read your data without a key.
3. Set `OPENAI_API_KEY`, `ANTHROPIC_API_KEY` or another provider key on the **Gateway** service.
4. Call the gateway from your app with that admin key, or with a key made on the UI's **API Keys** page:

```bash
curl https://YOUR-GATEWAY-DOMAIN/openai/v1/chat/completions \
  -H "Authorization: Bearer YOUR-TENSORZERO-API-KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "tensorzero::model_name::openai::gpt-4o-mini", "messages": [{"role": "user", "content": "Hello"}]}'
```

To define functions, variants, metrics or other models, put TOML in the Gateway's `TENSORZERO_CONFIG_TOML` variable (loaded next to the template's base config) and redeploy. Every service runs within 0.5 GB of RAM. ClickHouse is left out: TensorZero recommends it only above about 100 inferences per second, and you can add it later with `TENSORZERO_CLICKHOUSE_URL`. Updates: when this template moves to a newer TensorZero release, Railway shows an "update available" notice on your project. Read the repo's CHANGELOG first.

## Variables

| Service | Variable | Value |
|---|---|---|
| Postgres | `POSTGRES_PASSWORD` | generated (32 characters) |
| Postgres | `DATABASE_URL` | built from the password and the private domain |
| Gateway | `TENSORZERO_ADMIN_API_KEY` | generated `sk-t0-…` admin key, registered on start |
| Gateway | `TENSORZERO_POSTGRES_URL` | `${{Postgres.DATABASE_URL}}` |
| Gateway | `OPENAI_API_KEY`, `ANTHROPIC_API_KEY` | optional provider keys (add any other provider's variable the same way) |
| Gateway | `TENSORZERO_CONFIG_TOML` | optional extra TensorZero config (add it yourself) |
| UI | `TENSORZERO_GATEWAY_URL` | the gateway's private URL |
| UI | `TENSORZERO_POSTGRES_URL` | `${{Postgres.DATABASE_URL}}` (API keys page) |

## Updates

Each service's Dockerfile pins the upstream image by version and digest. When the pin moves to a newer
TensorZero release on `main`, Railway shows deployers an "update available" notice; the gateway applies
new Postgres migrations on its next start. See [CHANGELOG.md](CHANGELOG.md).

## Why Deploy TensorZero on Railway?

<!-- Recommended: Keep this section as shown below -->
Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying TensorZero on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
<!-- End recommended section -->
