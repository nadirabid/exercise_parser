BEGIN;

ALTER TABLE users ADD COLUMN IF NOT EXISTS roles character varying(250)[];

COMMIT;
