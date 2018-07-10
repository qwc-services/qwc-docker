#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
  CREATE ROLE qgis_server LOGIN PASSWORD 'qgis_server';
  CREATE ROLE qwc_admin LOGIN PASSWORD 'qwc_admin';
  CREATE ROLE qwc_service LOGIN PASSWORD 'qwc_service';
  CREATE ROLE qwc_service_write LOGIN PASSWORD 'qwc_service_write';

  CREATE DATABASE qwc_demo;
  COMMENT ON DATABASE qwc_demo IS 'Demo DB for qwc-services';
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d qwc_demo <<-EOSQL
  CREATE SCHEMA qwc_config AUTHORIZATION qwc_admin;
  COMMENT ON SCHEMA qwc_config IS 'Configurations for qwc-services';
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d qwc_demo <<-EOSQL
  CREATE EXTENSION postgis;
  GRANT SELECT ON TABLE geometry_columns TO PUBLIC;
  GRANT SELECT ON TABLE geography_columns TO PUBLIC;
  GRANT SELECT ON TABLE spatial_ref_sys TO PUBLIC;

  CREATE SCHEMA qwc_geodb;
  COMMENT ON SCHEMA qwc_geodb IS 'Demo GeoDB for qwc-services';
  GRANT USAGE ON SCHEMA qwc_geodb TO qgis_server;
  GRANT ALL ON SCHEMA qwc_geodb TO qwc_admin;
  GRANT USAGE ON SCHEMA qwc_geodb TO qwc_service;
  GRANT ALL ON SCHEMA qwc_geodb TO qwc_service_write;
EOSQL
