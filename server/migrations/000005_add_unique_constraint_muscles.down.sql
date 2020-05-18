BEGIN;

ALTER TABLE muscles REMOVE CONSTRAINT muscles_exercise_dictionary_id UNIQUE (exercise_dictionary_id);

COMMIT;