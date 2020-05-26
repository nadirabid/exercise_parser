BEGIN;

CREATE TABLE IF NOT EXISTS resolved_exercise_dictionaries (
  id SERIAL PRIMARY KEY,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  deleted_at timestamp with time zone,
  exercise_id integer REFERENCES exercises(id) ON DELETE CASCADE,
  exercise_dictionary_id integer REFERENCES exercise_dictionaries(id) ON DELETE CASCADE
);

COMMIT;
