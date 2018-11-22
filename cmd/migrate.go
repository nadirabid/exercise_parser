package cmd

import (
	"fmt"

	"github.com/golang-migrate/migrate"
	_ "github.com/golang-migrate/migrate/database/postgres" // required for migrate
	_ "github.com/golang-migrate/migrate/source/file"       // reguired for migrate
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

func newMigrate(v *viper.Viper) (*migrate.Migrate, error) {
	dir := v.GetString("migrations.dir")
	host := v.GetString("psql.host")
	port := v.GetString("psql.port")
	sslmode := v.GetString("psql.sslmode")
	user := v.GetString("psql.user")
	password := v.GetString("psql.password")
	database := v.GetString("psql.database")

	if ok, err := isDirectory(dir); err != nil {
		return nil, err
	} else if !ok {
		return nil, fmt.Errorf("Specified migrations directory was not found: %s", dir)
	}

	m, err := migrate.New(pathToFileURL(dir), fmt.Sprintf(
		"postgres://%s:%s?sslmode=%s&dbname=%s&user=%s&password=%s",
		host,
		port,
		sslmode,
		database,
		user,
		password,
	))

	if err != nil {
		return nil, err
	}

	return m, nil
}

func reportMigrationSuccess(m *migrate.Migrate) {
	fmt.Println("Success! the migration has been run.")

	if v, _, err := m.Version(); err != nil {
		fmt.Printf("Unable to check the latest version of the database: %s.\n", err)
	} else {
		fmt.Printf("Database is now at version %d.\n", v)
	}
}

func drop(cmd *cobra.Command, args []string) error {
	v, err := configureViperFromCmd(cmd)
	if err != nil {
		return err
	}

	m, err := newMigrate(v)
	if err != nil {
		return err
	}

	if err := m.Down(); err != nil {
		return err
	}

	reportMigrationSuccess(m)

	return nil
}

func up(cmd *cobra.Command, args []string) error {
	v, err := configureViperFromCmd(cmd)
	if err != nil {
		return err
	}

	m, err := newMigrate(v)
	if err != nil {
		return err
	}

	if err := m.Up(); err != nil {
		return err
	}

	reportMigrationSuccess(m)

	return nil
}

var dropCmd = &cobra.Command{
	Use:   "drop",
	Short: "Delete everything in the database",
	RunE:  drop,
}

var upCmd = &cobra.Command{
	Use:   "up",
	Short: "Apply migrations upwards",
	RunE:  up,
}

// migrateCmd represents the migrate command
var migrateCmd = &cobra.Command{
	Use:   "migrate",
	Short: "Manage migrations",
}

func init() {
	rootCmd.AddCommand(migrateCmd)

	migrateCmd.AddCommand(upCmd)
	upCmd.Flags().String("conf", "dev", "The conf file name to use.")

	migrateCmd.AddCommand(dropCmd)
	dropCmd.Flags().String("conf", "dev", "The conf file name to use.")
}
