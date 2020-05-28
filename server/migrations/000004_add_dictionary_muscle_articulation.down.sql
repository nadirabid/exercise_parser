BEGIN;

ALTER TABLE muscles
DROP COLUMN IF EXISTS dynamic_articulation,
DROP COLUMN IF EXISTS static_articulation;

COMMIT;
