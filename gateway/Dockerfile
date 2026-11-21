# TensorZero Gateway (LLM gateway: inference, feedback, observability).
FROM tensorzero/gateway:2026.6.0@sha256:c939db4f27e41aa3a37a87909430a0c8f898f9c952f402dcbdc17e1708597bcb

USER root
# psql: the start script stores the generated admin API key in Postgres.
RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-client \
 && rm -rf /var/lib/apt/lists/*
COPY config/ /app/config/
COPY start.sh /usr/local/bin/start.sh
RUN chmod 755 /usr/local/bin/start.sh && mkdir -p /app/config/custom && chown gateway /app/config/custom
USER gateway

# Size Tokio's worker pool to the service, not the host (override for bigger services).
ENV TOKIO_WORKER_THREADS=2
ENTRYPOINT ["/usr/local/bin/start.sh"]
