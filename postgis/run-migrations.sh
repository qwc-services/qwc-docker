#!/bin/bash
set -e

# run migrations from qwc-config-db
cd /tmp/qwc-config-db/
alembic upgrade $ALEMBIC_VERSION
