#!/bin/sh

cd /tmp

curl -L https://qwc2.sourcepole.ch/data/qwc_geodb.backup > qwc_geodb.backup
pg_restore -U "$POSTGRES_USER" -d qwc_services -1 qwc_geodb.backup
