-- https://medium.com/@Umesh_Kafle/postgresql-and-postgis-installation-in-mac-os-87fa98a6814d
-- https://medium.com/coding-blocks/creating-user-database-and-adding-access-on-postgresql-8bfcd2f4a91e
-- Run this file like: `psql -d postgres -f setup.sql`
-- Access DB: psql -d exercise_parser

CREATE DATABASE exercise_parser;
CREATE USER exercise WITH PASSWORD 'parser';
GRANT ALL PRIVILEGES ON DATABASE exercise_parser TO exercise;
