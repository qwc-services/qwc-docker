#!/bin/bash
set -e

echo "Setting up passwords for QWC users..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "qwc_services" <<-EOSQL
    ALTER USER qwc_admin WITH PASSWORD 'qwc_admin';
    ALTER USER qwc_service WITH PASSWORD 'qwc_service';
    ALTER USER qwc_service_write WITH PASSWORD 'qwc_service_write';
EOSQL

echo "Passwords configured successfully."