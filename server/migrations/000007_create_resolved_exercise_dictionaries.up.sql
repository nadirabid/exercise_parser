BEGIN;

CREATE TABLE IF NOT EXISTS resolved_exercise_dictionaries (
  id SERIAL PRIMARY KEY,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  deleted_at timestamp with time zone,
  exercise_id integer REFERENCES exercises(id) ON DELETE CASCADE,
  exercise_dictionary_id integer REFERENCES exercise_dictionaries(id) ON DELETE CASCADE
);

---- Copy over data from exercise.exercise_dictionary_id to new join table ----

INSERT INTO resolved_exercise_dictionaries (exercise_id, exercise_dictionary_id)
SELECT id, exercise_dictionary_id
FROM exercises
WHERE exercises.exercise_dictionary_id IS NOT NULL;

---- Update type (aka ParseType) to full if exercise.name is not null ---

UPDATE exercises SET type = 'full'
WHERE exercises.name != '';

UPDATE exercises SET type = ''
WHERE exercises.name = 'full';

---- Update resolution_type based on exercise_dictionary_id ----

UPDATE exercises SET resolution_type = 'auto.single'
WHERE exercises.exercise_dictionary_id IS NOT NULL;

UPDATE exercises SET resolution_type = ''
WHERE exercises.exercise_dictionary_id IS NULL;

COMMIT;
