BEGIN;

-- WorkoutTemplates ----------------------------------------------

CREATE TABLE IF NOT EXISTS workout_templates (
  id SERIAL PRIMARY KEY,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  deleted_at timestamp with time zone,
  user_id integer REFERENCES users(id) ON DELETE CASCADE,
  name text
);

-- ExerciseTemplates ----------------------------------------------

CREATE TABLE IF NOT EXISTS exercise_templates (
  id SERIAL PRIMARY KEY,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  deleted_at timestamp with time zone,
  name text,
  workout_template_id integer REFERENCES workout_templates(id) ON DELETE CASCADE,
  circuit_id integer,
  circuit_rounds integer NOT NULL DEFAULT 1
);

-- ExerciseTemplateData ----------------------------------------------

CREATE TABLE IF NOT EXISTS exercise_template_data (
    id SERIAL PRIMARY KEY,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,

    is_sets_field_enabled boolean,
    is_reps_field_enabled boolean,
    is_weight_field_enabled boolean,
    is_time_field_enabled boolean,
    is_distance_field_enabled boolean,
    is_calories_field_enabled boolean,

    sets integer,
    reps integer[],
    weight float[],
    time integer[],
    distance float[],
    calories integer[],

    exercise_template_id integer REFERENCES exercise_templates(id) ON DELETE CASCADE
);

-- ExerciseTemplateToExerciseDictionaries ----------------------------------------------

CREATE TABLE IF NOT EXISTS exercise_template_to_exercise_dictionaries (
  id SERIAL PRIMARY KEY,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  deleted_at timestamp with time zone,
  exercise_template_id integer REFERENCES exercise_templates(id) ON DELETE CASCADE,
  exercise_dictionary_id integer REFERENCES exercise_dictionaries(id) ON DELETE CASCADE
);

COMMIT;
