BEGIN;

ALTER TABLE exercise_dictionaries DROP COLUMN IF EXISTS tsv;

COMMIT;
