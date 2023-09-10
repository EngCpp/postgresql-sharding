#!/bin/bash
set -e
export PGPASSWORD=$POSTGRES_PASSWORD;
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  BEGIN;
    CREATE TABLE IF NOT EXISTS customers_2023 (
	id BIGINT NOT NULL,
	name 	varchar(40),
	phone   varchar(15),
	email   varchar(20),
	registrationDate timestamp not null
    );
  COMMIT;
  
  CREATE USER fdw_user WITH ENCRYPTED PASSWORD'secret';
  GRANT SELECT,INSERT,UPDATE,DELETE ON TABLE customers_2023 TO fdw_user;
EOSQL
