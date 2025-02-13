#!/bin/sh

# Add resources and permissions for demo data
qwc_config_schema=${QWC_CONFIG_SCHEMA:-qwc_config}
psql -v ON_ERROR_STOP=1 "service=$PGSERVICE" <<-EOSQL
INSERT INTO ${qwc_config_schema}.resources (id, parent_id, type, name)
VALUES
  (1, NULL, 'solr_facet', 'ne_10m_admin_0_countries'),
  (2, NULL, 'map', 'qwc_demo'),
  (3, 2, 'data', 'edit_points'),
  (4, 2, 'data', 'edit_lines'),
  (5, 2, 'data', 'edit_polygons');
INSERT INTO ${qwc_config_schema}.permissions (id, role_id, resource_id, priority, write)
VALUES
  (1, 1, 1, 0, FALSE),
  (5, 1, 2, 0, FALSE),
  (2, 2, 4, 0, TRUE),
  (3, 2, 3, 0, TRUE),
  (4, 2, 5, 0, TRUE)
EOSQL
