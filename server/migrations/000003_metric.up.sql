BEGIN;

-- Metric ----------------------------------------------

CREATE TABLE IF NOT EXISTS metrics (
  id SERIAL PRIMARY KEY,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  deleted_at timestamp with time zone,
  workout_id integer REFERENCES workouts(id) ON DELETE CASCADE
);

-- TopLevelMetric ----------------------------------------------

CREATE TABLE IF NOT EXISTS top_level_metrics (
  id SERIAL PRIMARY KEY,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  deleted_at timestamp with time zone,
  sets integer,
  reps integer,
  seconds_elapsed integer,
  metric_id integer REFERENCES metrics(id) ON DELETE CASCADE
);

-- MuscleMetric ----------------------------------------------

CREATE TABLE IF NOT EXISTS muscle_metrics (
  id SERIAL PRIMARY KEY,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  deleted_at timestamp with time zone,
  metric_id integer REFERENCES metrics(id) ON DELETE CASCADE
)

-- MuscleStats ----------------------------------------------

CREATE TABLE IF NOT EXISTS muscle_stats (
  id SERIAL PRIMARY KEY,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  deleted_at timestamp with time zone,
  muscle character varying(250)[],
  reps int,
  muscle_metric_id integer REFERENCES muscle_metric(id) ON DELETE CASCADE
);

COMMIT;
