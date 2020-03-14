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
	sslmode := v.GetString("psql.sslmode")

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
func Migrate(db *gorm.DB) {
	// User models
	db.AutoMigrate(&User{})
	db.AutoMigrate(&Workout{})
	db.AutoMigrate(&Exercise{})
	db.AutoMigrate(&WeightedExercise{})
	db.AutoMigrate(&DistanceExercise{})

	// Dictionary models
	db.AutoMigrate(&ExerciseDictionary{})
	db.AutoMigrate(&ExerciseRelatedName{})
	db.AutoMigrate(&Classification{})
	db.AutoMigrate(&Muscles{})
	db.AutoMigrate(&Articulation{})
	db.AutoMigrate(&Joints{})
}
