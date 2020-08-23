BEGIN

ALTER TABLE workout_templates
DROP COLUMN IF EXISTS elapsed_seconds,
DROP COLUMN IF EXISTS is_not_template;

COMMIT;
