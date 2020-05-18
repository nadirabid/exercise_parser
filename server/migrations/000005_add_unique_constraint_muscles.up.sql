BEGIN;

ALTER TABLE muscles ADD CONSTRAINT muscles_exercise_dictionary_id UNIQUE (exercise_dictionary_id);

COMMIT;
