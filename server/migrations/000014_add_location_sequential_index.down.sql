BEGIN;

ALTER TABLE locations
DROP COLUMN IF EXISTS index;

COMMIT;