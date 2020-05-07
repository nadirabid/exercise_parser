package models

import (
	"fmt"

	"github.com/golang-migrate/migrate"
	_ "github.com/golang-migrate/migrate/database/postgres"
	_ "github.com/golang-migrate/migrate/source/file"

	"github.com/jinzhu/gorm"
	"github.com/spf13/viper"
)

// NewDatabase creates a new sql.DB instance
func NewDatabase(v *viper.Viper) (*gorm.DB, error) {
	host := v.GetString("psql.host")
	port := v.GetString("psql.port")
	user := v.GetString("psql.user")
	password := v.GetString("psql.password")
	database := v.GetString("psql.database")
	sslmode := v.GetString("psql.ssl_mode")

	db, err := gorm.Open("postgres", fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		host,
		port,
		user,
		password,
		database,
		sslmode,
	))

	db.LogMode(v.GetBool("psql.logging"))

	if err != nil {
		return nil, err
	}

	// WHY?: https://stackoverflow.com/questions/40032685/on-aws-rds-postgres-how-to-have-dictionaries-and-unaccented-full-text-search
	if err := db.Exec(fmt.Sprintf("ALTER ROLE %s IN DATABASE %s SET default_text_search_config TO 'pg_catalog.english'", user, database)).Error; err != nil {
		return nil, err
	}

	return db, err
}

func Migrate(v *viper.Viper) error {
	host := v.GetString("psql.host")
	port := v.GetString("psql.port")
	user := v.GetString("psql.user")
	password := v.GetString("psql.password")
	database := v.GetString("psql.database")
	sslmode := v.GetString("psql.ssl_mode")

	fmt.Println("Migrations startings...")

	m, err := migrate.New(
		fmt.Sprintf("file://%s", v.GetString("migration.dir")),
		fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=%s", user, password, host, port, database, sslmode),
	)

	if err != nil {
		return err
	}

	if err := m.Up(); err != nil {
		return err
	}

	fmt.Println("Migrations completed!!!")

	return nil
}
