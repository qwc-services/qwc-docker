#!/bin/sh

cd /tmp

if command -v curl >/dev/null 2>&1; then
  curl -L https://qwc2.sourcepole.ch/data/qwc_geodb.backup -o qwc_geodb.backup
elif command -v wget >/dev/null 2>&1; then
  wget -O qwc_geodb.backup https://qwc2.sourcepole.ch/data/qwc_geodb.backup
else
  echo "ERROR: neither curl nor wget is available in the container"
  exit 127
fi
pg_restore -U "$POSTGRES_USER" -d qwc_services -1 qwc_geodb.backup

echo "Running custom DDL scripts..."
for f in /docker-entrypoint-initdb.d/sql/ddl/*.sql; do
  [ -f "$f" ] && echo "Running $f" && psql -U postgres -d qwc_services -v ON_ERROR_STOP=1 -f "$f"
done

echo "Running sensitive data scripts..."
for f in /docker-entrypoint-initdb.d/sql/sensitive/*.sql; do
  [ -f "$f" ] && echo "Running $f" && psql -U postgres -d qwc_services -v ON_ERROR_STOP=1 -f "$f"
done