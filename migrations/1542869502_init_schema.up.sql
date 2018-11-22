BEGIN;

CREATE TABLE exercises (
	id serial NOT NULL PRIMARY KEY,
	raw text NOT NULL,
	type text NOT NULL,
	name text NOT NULL
);


CREATE TABLE distance_exercise (
	id serial NOT NULL PRIMARY KEY,
	time text NOT NULL,
	distance real NOT NULL,
	units text NOT NULL,
	exercise_id bigint NOT NULL REFERENCES exercises(id)
);


CREATE TABLE weighted_exercises (
	id serial NOT NULL PRIMARY KEY,
	sets bigint NOT NULL,
	reps bigint NOT NULL,
	exercise_id bigint NOT NULL REFERENCES exercises(id)
);


COMMIT;
