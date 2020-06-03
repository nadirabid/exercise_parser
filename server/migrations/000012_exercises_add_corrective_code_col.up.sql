BEGIN;

ALTER TABLE exercises
ADD COLUMN IF NOT EXISTS corrective_code integer DEFAULT 0;

COMMIT;
