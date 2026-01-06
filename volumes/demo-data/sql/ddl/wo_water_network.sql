CREATE TABLE qwc_geodb.wo_water_network (
    id integer,
    pipeline_execution_time timestamp with time zone,
    pipeline_id uuid,
    creation_time timestamp with time zone DEFAULT now(),
    update_time timestamp with time zone DEFAULT now(),
    source_name text COLLATE pg_catalog."default",
    source_id text COLLATE pg_catalog."default",
    local_activity_level2_name text COLLATE pg_catalog."default",
    contract_code text COLLATE pg_catalog."default",
    contract_name text COLLATE pg_catalog."default",
    work_site_id text COLLATE pg_catalog."default",
    asset_id text COLLATE pg_catalog."default",
    request_reason_code_emitter text COLLATE pg_catalog."default",
    request_reason_name_emitter text COLLATE pg_catalog."default",
    action_code_emitter text COLLATE pg_catalog."default",
    action_name_emitter text COLLATE pg_catalog."default",
    intervention_stage_name_emitter text COLLATE pg_catalog."default",
    intervention_description text COLLATE pg_catalog."default",
    intervention_status_name_emitter text COLLATE pg_catalog."default",
    request_reason_type_name_emitter text COLLATE pg_catalog."default",
    street_number text COLLATE pg_catalog."default",
    street_name text COLLATE pg_catalog."default",
    street_name_added_information text COLLATE pg_catalog."default",
    city_name text COLLATE pg_catalog."default",
    workorder_periodicity_value text COLLATE pg_catalog."default",
    workorder_periodicity_code_emitter text COLLATE pg_catalog."default",
    request_emergency text COLLATE pg_catalog."default",
    execution_date_start timestamp without time zone,
    intervention_date_expected timestamp without time zone,
    workorder_date_start_target timestamp without time zone,
    workorder_date_end_target timestamp without time zone,
    execution_time integer,
    expected_time integer,
    execution_date_end timestamp without time zone,
    geometry text COLLATE pg_catalog."default",
    geom geometry(Point,3857),
    tsvector tsvector,
    asset_cmms_asset_name text COLLATE pg_catalog."default",
    source_uid text COLLATE pg_catalog."default",
    planner_id text COLLATE pg_catalog."default",
    cri_url text COLLATE pg_catalog."default",
    type_table_emitter text COLLATE pg_catalog."default",
    type_name_emitter text COLLATE pg_catalog."default",
    moveo_id text,
    task_id text,
    datadesk_id text,
    trgm text
);

GRANT SELECT ON TABLE qwc_geodb.wo_water_network TO qwc_service_write;
-- TODO add GRANT for other roles as needed
--GRANT SELECT ON TABLE qwc_geodb.wo_water_network TO qwc_service_write; 

CREATE UNIQUE INDEX IF NOT EXISTS wo_water_network_id_pkey ON qwc_geodb.wo_water_network USING btree (id);
CREATE UNIQUE INDEX IF NOT EXISTS wo_water_network_task_id_key ON qwc_geodb.wo_water_network USING btree (task_id);
CREATE UNIQUE INDEX IF NOT EXISTS wo_water_network_datadesk_id_key ON qwc_geodb.wo_water_network USING btree (datadesk_id);
CREATE INDEX IF NOT EXISTS wo_water_network_geom_idx ON qwc_geodb.wo_water_network USING gist (geom);
CREATE INDEX IF NOT EXISTS wo_water_network_contract_code_idx ON qwc_geodb.wo_water_network USING btree (contract_code);
CREATE INDEX IF NOT EXISTS wo_water_network_tsvector_idx ON qwc_geodb.wo_water_network USING gin (tsvector);
CREATE INDEX IF NOT EXISTS wo_water_network_moveo_id ON qwc_geodb.wo_water_network USING btree (moveo_id);
--CREATE INDEX IF NOT EXISTS wo_water_network_trgm_idx ON qwc_geodb.wo_water_network USING gin (trgm gin_trgm_ops);
