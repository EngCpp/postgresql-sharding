#!/bin/bash
set -e
export PGPASSWORD=$POSTGRES_PASSWORD;
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  BEGIN;
    CREATE TABLE IF NOT EXISTS customers (
	id BIGINT NOT NULL,
	name 	varchar(40),
	phone   varchar(15),
	email   varchar(20),
	registrationDate date not null
    ) PARTITION BY RANGE(registrationDate);
  COMMIT;
    
   CREATE EXTENSION postgres_fdw;
 
   CREATE SERVER pg_shard_1 FOREIGN DATA WRAPPER postgres_fdw OPTIONS(dbname'$POSTGRES_DB',host'pg_shard_1',port'5432');
   CREATE SERVER pg_shard_2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS(dbname'$POSTGRES_DB',host'pg_shard_2',port'5432');
   CREATE SERVER pg_shard_3 FOREIGN DATA WRAPPER postgres_fdw OPTIONS(dbname'$POSTGRES_DB',host'pg_shard_3',port'5432');
   
   CREATE USER MAPPING for postgres SERVER pg_shard_1 OPTIONS(user'fdw_user',password'secret');
   CREATE USER MAPPING for postgres SERVER pg_shard_2 OPTIONS(user'fdw_user',password'secret');
   CREATE USER MAPPING for postgres SERVER pg_shard_3 OPTIONS(user'fdw_user',password'secret');

   GRANT USAGE ON FOREIGN DATA WRAPPER postgres_fdw to postgres;   
   GRANT USAGE ON FOREIGN SERVER pg_shard_1 TO postgres;
   GRANT USAGE ON FOREIGN SERVER pg_shard_2 TO postgres;
   GRANT USAGE ON FOREIGN SERVER pg_shard_3 TO postgres;

   CREATE FOREIGN TABLE customers_2021 PARTITION OF customers FOR VALUES FROM('2021-01-01')TO('2021-12-31') SERVER pg_shard_1;
   CREATE FOREIGN TABLE customers_2022 PARTITION OF customers FOR VALUES FROM('2022-01-01')TO('2022-12-31') SERVER pg_shard_2;
   CREATE FOREIGN TABLE customers_2023 PARTITION OF customers FOR VALUES FROM('2023-01-01')TO('2023-12-31') SERVER pg_shard_3;    
EOSQL
