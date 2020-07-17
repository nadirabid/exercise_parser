BEGIN;

DROP TABLE IF EXISTS workout_templates CASCADE;
DROP TABLE IF EXISTS exercise_templates CASCADE;
DROP TABLE IF EXISTS exercise_template_data CASCADE;
DROP TABLE IF EXISTS exercise_template_to_exercise_dictionaries CASCADE;

COMMIT;
