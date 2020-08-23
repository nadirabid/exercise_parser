BEGIN;

ALTER TABLE workout_templates
ADD COLUMN IF NOT EXISTS seconds_elapsed integer,
ADD COLUMN IF NOT EXISTS is_not_template boolean NOT NULL default FALSE;

COMMIT;
