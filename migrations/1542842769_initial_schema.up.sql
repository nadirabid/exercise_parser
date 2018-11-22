BEGIN;

CREATE TABLE distance_exercise (
	id serial NOT NULL PRIMARY KEY,
	exercise text NOT NULL,
	time text NOT NULL,
	distance real NOT NULL,
	units real NOT NULL
);


CREATE TABLE exercises (
	id serial NOT NULL PRIMARY KEY,
	raw text NOT NULL
);


CREATE TABLE weighted_exercises (
	id serial NOT NULL PRIMARY KEY,
	exercise text NOT NULL,
	sets bigint NOT NULL,
	reps bigint NOT NULL
);


COMMIT;
