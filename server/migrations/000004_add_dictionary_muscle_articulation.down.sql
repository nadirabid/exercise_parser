BEGIN;

ALTER TABLE muscles
DROP COLUMN IF EXISTS dynamic_articulation character varying(250)[],
DROP COLUMN IF EXISTS static_articulation character varying(250)[];

COMMIT;
