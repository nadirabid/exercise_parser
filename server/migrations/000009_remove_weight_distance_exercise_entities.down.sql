BEGIN;

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

CREATE INDEX IF NOT EXISTS idx_weighted_exercises_deleted_at ON weighted_exercises(deleted_at timestamptz_ops);

COMMIT;
