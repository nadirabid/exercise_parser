BEGIN;

ALTER TABLE workouts
DROP COLUMN IF EXISTS in_progress;

COMMIT;
