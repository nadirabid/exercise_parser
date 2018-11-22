package models

import (
	"database/sql"
	"fmt"

	"github.com/spf13/viper"
)

// NewDatabase creates a new sql.DB instance
func NewDatabase(v *viper.Viper) (*sql.DB, error) {
	host := v.GetString("psql.host")
	port := v.GetString("psql.port")
	sslmode := v.GetString("psql.sslmode")
	user := v.GetString("psql.user")
	password := v.GetString("psql.password")
	database := v.GetString("psql.database")

	return sql.Open("postgres", fmt.Sprintf(
		"postgres://%s:%s?sslmode=%s&dbname=%s&user=%s&password=%s",
		host,
		port,
		sslmode,
		database,
		user,
		password,
	))
}
