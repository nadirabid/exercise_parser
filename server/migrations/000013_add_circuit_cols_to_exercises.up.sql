BEGIN;

ALTER TABLE exercises
ADD COLUMN IF NOT EXISTS circuit_id integer,
ADD COLUMN IF NOT EXISTS circuit_rounds integer NOT NULL DEFAULT 1;

COMMIT;
