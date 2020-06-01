BEGIN;

ALTER TABLE users
ADD COLUMN IF NOT EXISTS birthdate timestamp with time zone,
ADD COLUMN IF NOT EXISTS weight numeric,
ADD COLUMN IF NOT EXISTS height numeric,
ADD COLUMN IF NOT EXISTS is_male boolean;

ALTER TABLE metrics_top_level 
ADD COLUMN IF NOT EXISTS calories integer;

COMMIT;
