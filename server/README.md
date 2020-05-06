#### Materials

* [PostgreSQL Text Search](http://shisaa.jp/postset/postgresql-full-text-search-part-3.html)
* [Muscle Book](https://github.com/cfilipov/MuscleBook/tree/master/MuscleBook)

#### Create Database

```
psql -d postgres -f setup.sql
```

To access db on terminal:

```
psql -d exercise_parser
```

Also - download Postico for Mac - super good.

#### Migration

Using `golang-migrate`. Install CLI to generate the files:

```
brew install golang-migrate
```

To generate new migration files:

```
migrate create -ext sql -dir migrations -seq name_of_migration
```

For local testing - to create a db copy:

```sh
psql -d exercise_parser
CREATE DATABASE exercise_parser_test WITH TEMPLATE exercise_parser OWNER exercise_parser;
```

#### Examples

* [0](https://www.instagram.com/dailylifts365/)
* [1](https://www.instagram.com/p/BY7EIqvA1_C/)
* [2](https://www.instagram.com/p/B9ctyA0n4As/)
* [3](https://www.instagram.com/p/B9csO4Eh6Ez/)
* [4](https://www.instagram.com/p/B9clg8ulDe_/)
* [5](https://www.instagram.com/p/B9aIOuDj90c/)
* [6](https://www.instagram.com/p/B9c77IagavC/)
* [7](https://www.instagram.com/p/B9cz1s2jBsS/)
* [8](https://www.instagram.com/p/B9cgZZyFtSV/)
* [9](https://www.instagram.com/p/B9cdp77nLZr/)

