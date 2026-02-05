#!/bin/sh
# DB init with debugging and more visibility 
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

echo "===================="
echo "Running custom DDL scripts..."
echo "===================="
for f in /docker-entrypoint-initdb.d/sql/ddl/*.sql; do
  if [ -f "$f" ]; then
    echo ">>> Executing: $f"
    psql -U postgres -d qwc_services -v ON_ERROR_STOP=1 -f "$f"
    if [ $? -eq 0 ]; then
      echo "✓ Successfully executed: $f"
    else
      echo "✗ Failed to execute: $f"
    fi
  else
    echo "⚠ File not found: $f"
  fi
done

echo "===================="
echo "Running sensitive data scripts..."
echo "===================="
for f in /docker-entrypoint-initdb.d/sql/sensitive/*.sql; do
  if [ -f "$f" ]; then
    echo ">>> Executing: $f"
    psql -U postgres -d qwc_services -v ON_ERROR_STOP=1 -f "$f"
    if [ $? -eq 0 ]; then
      echo "✓ Successfully executed: $f"
    else
      echo "✗ Failed to execute: $f"
    fi
  else
    echo "⚠ File not found: $f"
  fi
done

echo "===================="
echo "All custom scripts executed!"
echo "===================="