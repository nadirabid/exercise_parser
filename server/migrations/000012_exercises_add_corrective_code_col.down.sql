BEGIN;

ALTER TABLE exercises
DROP COLUMN IF EXISTS corrective_code;

COMMIT;
