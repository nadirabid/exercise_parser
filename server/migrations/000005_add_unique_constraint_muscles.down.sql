BEGIN;

ALTER TABLE muscles DROP CONSTRAINT muscles_exercise_dictionary_id;

COMMIT;