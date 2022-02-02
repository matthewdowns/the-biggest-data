#!/bin/sh
set -e

# https://docs.timescale.com/timescaledb/latest/how-to-guides/configuration/timescaledb-config/#timescaledb-last-tuned-string
# https://docs.timescale.com/timescaledb/latest/how-to-guides/multi-node-setup/required-configuration/

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "SHOW config_file"
# To achieve good query performance you need to enable partition-wise aggregation on the access node. This pushes down aggregation queries to the data nodes.
# https://www.postgresql.org/docs/12/runtime-config-query.html#enable_partitionwise_aggregate
sed -ri "s!^#?(enable_partitionwise_aggregate)\s*=.*!\1 = on!" /var/lib/postgresql/data/postgresql.conf
grep "enable_partitionwise_aggregate" /var/lib/postgresql/data/postgresql.conf
# JIT should be set to off on the access node as JIT currently doesn't work well with distributed queries.
# https://www.postgresql.org/docs/12/runtime-config-query.html#jit
sed -ri "s!^#?(jit)\s*=.*!\1 = off!" /var/lib/postgresql/data/postgresql.conf
grep "jit" /var/lib/postgresql/data/postgresql.conf

echo "Waiting for data nodes..."
until PGPASSWORD=$POSTGRES_PASSWORD psql -h tbd-data-node-1 -U "$POSTGRES_USER" -c '\q'; do
    sleep 5s
done
until PGPASSWORD=$POSTGRES_PASSWORD psql -h tbd-data-node-2 -U "$POSTGRES_USER" -c '\q'; do
    sleep 5s
done

echo "Add data nodes to access node..."
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" <<-EOSQL
SELECT add_data_node('tbd_data_node_1', host => 'tbd_data_node_1');
SELECT add_data_node('tbd_data_node_2', host => 'tbd_data_node_2');
EOSQL

echo "Create distributed samples table..."
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" <<-EOSQL
CREATE TABLE samples
(
    timestamp  TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    key        VARCHAR(20)      NOT NULL,
    value      DOUBLE PRECISION NOT NULL,
    CONSTRAINT samples_pkey PRIMARY KEY (timestamp, key)
);
SELECT create_distributed_hypertable(
    'samples', 'timestamp', 'key',
    number_partitions => 2,
    chunk_time_interval => INTERVAL '00:01:00',
    replication_factor => 1
);
EOSQL
