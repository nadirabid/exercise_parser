BEGIN;

-- Metric ----------------------------------------------

CREATE TABLE IF NOT EXISTS metrics (
  id SERIAL PRIMARY KEY,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  deleted_at timestamp with time zone,
  workout_id integer REFERENCES workouts(id) ON DELETE CASCADE
);

-- MetricTopLevel ----------------------------------------------

CREATE TABLE IF NOT EXISTS metrics_top_level (
  id SERIAL PRIMARY KEY,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  deleted_at timestamp with time zone,
  distance numeric,
  sets integer,
  reps integer,
  seconds_elapsed integer,
  metric_id integer REFERENCES metrics(id) ON DELETE CASCADE
);

-- MetricMuscle ----------------------------------------------

CREATE TABLE IF NOT EXISTS metrics_muscle (
  id SERIAL PRIMARY KEY,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  deleted_at timestamp with time zone,
  name text NOT NULL,
  usage text NOT NULL,
  reps int,
  metric_id integer REFERENCES metrics(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX idx_metric_id_and_usage_and_muscle ON metrics_muscle(metric_id, name, usage);

COMMIT;
