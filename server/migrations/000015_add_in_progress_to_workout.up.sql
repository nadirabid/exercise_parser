BEGIN;

ALTER TABLE workouts
ADD COLUMN IF NOT EXISTS in_progress boolean NOT NULL default FALSE;

COMMIT;
