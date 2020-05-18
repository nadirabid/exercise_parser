BEGIN;

ALTER TABLE muscles
ADD COLUMN IF NOT EXISTS dynamic_articulation character varying(250)[],
ADD COLUMN IF NOT EXISTS static_articulation character varying(250)[];

COMMIT;
