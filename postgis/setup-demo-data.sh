#!/bin/bash
set -e

# >>> from werkzeug.security import generate_password_hash
# >>> print(generate_password_hash('demo'))
psql -v ON_ERROR_STOP=1 --username qwc_admin -d qwc_demo <<-EOSQL
  INSERT INTO qwc_config.users (name, description, password_hash)
    VALUES('demo', 'Demo user', 'pbkdf2:sha256:50000$qwQxJa3a$91e81c06ce49eb76692e69f430e937dc5eac5b2f301eced831d0bd4e0f1e3120');
  -- password: 'demo'
EOSQL
