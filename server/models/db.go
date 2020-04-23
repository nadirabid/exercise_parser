package models

import (
	"fmt"

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

	return gorm.Open("postgres", fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		host,
		port,
		user,
		password,
		database,
		sslmode,
	))
}

// Migrate will auto migrate
func Migrate(db *gorm.DB) error {
	// Dictionary models
	err := db.

		// dictionary related models
		AutoMigrate(&ExerciseDictionary{}).
		AutoMigrate(&ExerciseRelatedName{}).
		AutoMigrate(&Classification{}).
		AutoMigrate(&Muscles{}).
		AutoMigrate(&Articulation{}).
		AutoMigrate(&Joints{}).

		// user related models
		AutoMigrate(&User{}).
		AutoMigrate(&Workout{}).
		AutoMigrate(&Location{}).
		AutoMigrate(&Exercise{}).
		AutoMigrate(&WeightedExercise{}).
		AutoMigrate(&DistanceExercise{}).
		Error

	return err
}

func DropAll(db *gorm.DB) error {
	err := db.
		Set("gorm:table_options", "CASCADE").
		DropTableIfExists(
			&Joints{},
			&Classification{},
			&Muscles{},
			&Articulation{},
			&ExerciseRelatedName{},
			&ExerciseDictionary{},

			&DistanceExercise{},
			&WeightedExercise{},
			&Exercise{},
			&Location{},
			&Workout{},
			&User{},
		).
		Error

	if err != nil {
		return fmt.Errorf("couldn't drop table: %s", err.Error())
	}

	return nil
}
