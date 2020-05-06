
BEGIN;

-- ExerciseDictionary ----------------------------------------------

CREATE TABLE IF NOT EXISTS exercise_dictionaries (
    id SERIAL PRIMARY KEY,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    url text,
    name text UNIQUE,
    tsv tsvector
);

CREATE UNIQUE INDEX IF NOT EXISTS exercise_dictionaries_pkey ON exercise_dictionaries(id int4_ops);
CREATE UNIQUE INDEX IF NOT EXISTS exercise_dictionaries_name_key ON exercise_dictionaries(name text_ops);
CREATE INDEX IF NOT EXISTS idx_exercise_dictionaries_deleted_at ON exercise_dictionaries(deleted_at timestamptz_ops);

-- ExerciseRelatedName ----------------------------------------------

CREATE TABLE IF NOT EXISTS exercise_related_names (
    id SERIAL PRIMARY KEY,
    exercise_dictionary_id integer REFERENCES exercise_dictionaries(id) ON DELETE SET NULL,
    related text NOT NULL,
    related_tsv tsvector,
    type text,
    ignored boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);

CREATE INDEX IF NOT EXISTS idx_exercise_related_names_deleted_at ON exercise_related_names(deleted_at timestamptz_ops);
CREATE UNIQUE INDEX IF NOT EXISTS exercise_related_names_pkey ON exercise_related_names(id int4_ops);

-- Muscles ----------------------------------------------

CREATE TABLE IF NOT EXISTS muscles (
    id SERIAL PRIMARY KEY,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    target character varying(250)[],
    synergists character varying(250)[],
    stabilizers character varying(250)[],
    dynamic_stabilizers character varying(250)[],
    antagonist_stabilizers character varying(250)[],
    rom_criteria character varying(250)[],
    exercise_dictionary_id integer REFERENCES exercise_dictionaries(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS muscles_pkey ON muscles(id int4_ops);
CREATE INDEX IF NOT EXISTS idx_muscles_deleted_at ON muscles(deleted_at timestamptz_ops);

-- Classification ----------------------------------------------

CREATE TABLE IF NOT EXISTS classifications (
    id SERIAL PRIMARY KEY,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    utility text,
    mechanics text,
    force text,
    intensity text,
    function text,
    bearing text,
    impact text,
    exercise_dictionary_id integer REFERENCES exercise_dictionaries(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS classifications_pkey ON classifications(id int4_ops);
CREATE INDEX IF NOT EXISTS idx_classifications_deleted_at ON classifications(deleted_at timestamptz_ops);

-- Articulation ----------------------------------------------

CREATE TABLE IF NOT EXISTS articulations (
    id SERIAL PRIMARY KEY,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    exercise_dictionary_id integer REFERENCES exercise_dictionaries(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS articulations_pkey ON articulations(id int4_ops);
CREATE INDEX IF NOT EXISTS idx_articulations_deleted_at ON articulations(deleted_at timestamptz_ops);

-- Joints ----------------------------------------------

CREATE TABLE IF NOT EXISTS joints (
    id SERIAL PRIMARY KEY,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    ankle character varying(250)[],
    elbow character varying(250)[],
    finger character varying(250)[],
    foot character varying(250)[],
    forearms character varying(250)[],
    hip character varying(250)[],
    scapula character varying(250)[],
    clavicle character varying(250)[],
    shoulder character varying(250)[],
    shoulder_girdle character varying(250)[],
    spine character varying(250)[],
    thumb character varying(250)[],
    wrist character varying(250)[],
    knee character varying(250)[],
    articulation_id integer REFERENCES articulations(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS joints_pkey ON joints(id int4_ops);
CREATE INDEX IF NOT EXISTS idx_joints_deleted_at ON joints(deleted_at timestamptz_ops);

-- User ----------------------------------------------

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    given_name text,
    family_name text,
    email text,
    external_user_id text NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS users_pkey ON users(id int4_ops);
CREATE INDEX IF NOT EXISTS idx_users_deleted_at ON users(deleted_at timestamptz_ops);
CREATE UNIQUE INDEX IF NOT EXISTS ext_id ON users(external_user_id text_ops);

-- Workout ----------------------------------------------

CREATE TABLE IF NOT EXISTS workouts (
    id SERIAL PRIMARY KEY,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    name text,
    date timestamp with time zone,
    seconds_elapsed integer,
    user_id integer REFERENCES users(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS workouts_pkey ON workouts(id int4_ops);
CREATE INDEX IF NOT EXISTS idx_workouts_deleted_at ON workouts(deleted_at timestamptz_ops);

-- Location ----------------------------------------------

CREATE TABLE IF NOT EXISTS locations (
    id SERIAL PRIMARY KEY,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    latitude numeric NOT NULL,
    longitude numeric NOT NULL,
    workout_id integer REFERENCES workouts(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS locations_pkey ON locations(id int4_ops);
CREATE INDEX IF NOT EXISTS idx_locations_deleted_at ON locations(deleted_at timestamptz_ops);

-- Exercise ----------------------------------------------

CREATE TABLE IF NOT EXISTS exercises (
    id SERIAL PRIMARY KEY,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    raw text,
    type text,
    resolution_type text,
    name text,
    exercise_dictionary_id integer REFERENCES exercise_dictionaries(id) ON DELETE SET NULL,
    workout_id integer REFERENCES workouts(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS exercises_pkey ON exercises(id int4_ops);
CREATE INDEX IF NOT EXISTS idx_exercises_deleted_at ON exercises(deleted_at timestamptz_ops);

-- ExerciseData ----------------------------------------------

CREATE TABLE IF NOT EXISTS exercise_data (
    id SERIAL PRIMARY KEY,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    sets integer,
    reps integer,
    weight numeric,
    time integer,
    distance numeric,
    exercise_id integer REFERENCES exercises(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS exercise_data_pkey ON exercise_data(id int4_ops);
CREATE INDEX IF NOT EXISTS idx_exercise_data_deleted_at ON exercise_data(deleted_at timestamptz_ops);

-- DistanceExercise ----------------------------------------------

CREATE TABLE IF NOT EXISTS distance_exercises (
    id SERIAL PRIMARY KEY,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    time integer,
    distance numeric,
    exercise_id integer REFERENCES exercises(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS distance_exercises_pkey ON distance_exercises(id int4_ops);
CREATE INDEX IF NOT EXISTS idx_distance_exercises_deleted_at ON distance_exercises(deleted_at timestamptz_ops);

-- WeightedExercise ----------------------------------------------

CREATE TABLE IF NOT EXISTS weighted_exercises (
    id SERIAL PRIMARY KEY,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    sets integer,
    reps integer,
    weight numeric,
    exercise_id integer REFERENCES exercises(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS weighted_exercises_pkey ON weighted_exercises(id int4_ops);
CREATE INDEX IF NOT EXISTS idx_weighted_exercises_deleted_at ON weighted_exercises(deleted_at timestamptz_ops);

COMMIT;
