#!/bin/bash
set -e

# import demo data into GeoDB
ogr2ogr -f PostgreSQL PG:"dbname=qwc_demo user=qwc_admin password=qwc_admin" -lco SCHEMA=qwc_geodb /tmp/demo_geodata.gpkg

psql -v ON_ERROR_STOP=1 --username qwc_admin -d qwc_demo <<-EOSQL
  GRANT SELECT ON ALL TABLES IN SCHEMA qwc_geodb TO qgis_server;
  GRANT SELECT ON ALL SEQUENCES IN SCHEMA qwc_geodb TO qgis_server;
  GRANT SELECT ON ALL TABLES IN SCHEMA qwc_geodb TO qwc_service;
  GRANT SELECT ON ALL SEQUENCES IN SCHEMA qwc_geodb TO qwc_service;
  GRANT ALL ON ALL TABLES IN SCHEMA qwc_geodb TO qwc_service_write;
  GRANT USAGE ON ALL SEQUENCES IN SCHEMA qwc_geodb TO qwc_service_write;
EOSQL

# insert demo records into ConfigDB
# >>> from werkzeug.security import generate_password_hash
# >>> print(generate_password_hash('demo'))
psql -v ON_ERROR_STOP=1 --username qwc_admin -d qwc_demo <<-EOSQL
  INSERT INTO qwc_config.users (name, description, password_hash)
    VALUES('demo', 'Demo user', 'pbkdf2:sha256:50000$qwQxJa3a$91e81c06ce49eb76692e69f430e937dc5eac5b2f301eced831d0bd4e0f1e3120');
  -- password: 'demo'
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d qwc_demo <<-EOSQL
  VACUUM FULL;
EOSQL
