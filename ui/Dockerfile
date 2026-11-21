# TensorZero UI (observability, evaluations, optimisation, API keys).
FROM tensorzero/ui:2026.6.0@sha256:f2563d54724eb969164a03d841cd56f330feb256ef7131ce2aa742498e81e8ec

# Keep Node's heap inside a 0.5 GB Railway service; override if you give the service more RAM.
ENV NODE_OPTIONS=--max-old-space-size=320
# The upstream entrypoint execs react-router-serve on $PORT (4000 by default).
