# TensorZero's Postgres image: official postgres 17.9 plus pg_cron and pgvector,
# which the TensorZero gateway needs (partition management and optimisation).
FROM tensorzero/postgres:17.9@sha256:18d70f96121fb461a0b6de616d80e799a4a9014943fcc3a52e2555dfb5ade878

# Railway volumes are root-owned and hold a lost+found folder, so run the
# entrypoint as root (it chowns and drops to the postgres user) and keep the
# cluster in a subfolder of the volume.
USER root
ENV PGDATA=/var/lib/postgresql/data/pgdata \
    POSTGRES_USER=postgres \
    POSTGRES_DB=tensorzero

# pg_cron must run in TensorZero's database.
CMD ["postgres", "-c", "cron.database_name=tensorzero"]
