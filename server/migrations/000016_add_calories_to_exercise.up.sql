BEGIN;

ALTER TABLE exercise_data
ADD COLUMN IF NOT EXISTS calories integer NOT NULL default 0;

COMMIT;
