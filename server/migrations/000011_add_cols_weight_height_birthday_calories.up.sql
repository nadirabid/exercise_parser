BEGIN;

ALTER TABLE users
ADD COLUMN IF NOT EXISTS birthdate timestamp with time zone,
ADD COLUMN IF NOT EXISTS weight integer,
ADD COLUMN IF NOT EXISTS height integer,
ADD COLUMN IF NOT EXISTS is_male boolean;

ALTER TABLE metrics_top_level 
ADD COLUMN IF NOT EXSTS calories integer;

COMMIT;
