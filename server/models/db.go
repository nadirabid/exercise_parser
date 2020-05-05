package models

import (
	"fmt"
	"time"

	"github.com/jinzhu/gorm"
	"github.com/spf13/viper"
	"gopkg.in/gormigrate.v1"
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

	if err != nil {
		return nil, err
	}

	// WHY?: https://stackoverflow.com/questions/40032685/on-aws-rds-postgres-how-to-have-dictionaries-and-unaccented-full-text-search
	if err := db.Exec(fmt.Sprintf("ALTER ROLE %s IN DATABASE %s SET default_text_search_config TO 'pg_catalog.english'", user, database)).Error; err != nil {
		return nil, err
	}

	return db, err
}

func migration(id string, callback func(id string) *gormigrate.Migration) *gormigrate.Migration {
	return callback(id)
}

func Migrate(db *gorm.DB) error {
	m := gormigrate.New(db, gormigrate.DefaultOptions, []*gormigrate.Migration{
		migration("5-4-2020x1", func(migrationID string) *gormigrate.Migration {
			type HiddenModel struct {
				ID        uint       `json:"-" gorm:"primary_key"`
				CreatedAt time.Time  `json:"-"`
				UpdatedAt time.Time  `json:"-"`
				DeletedAt *time.Time `json:"-" sql:"index"`
			}

			type ExerciseData struct {
				HiddenModel
				Sets       int     `json:"sets"`
				Reps       int     `json:"reps"`
				Weight     float32 `json:"weight"`
				Time       uint    `json:"time"`
				Distance   float32 `json:"distance"`
				ExerciseID uint    `json:"exercise_id" gorm:"type:int REFERENCES exercises(id) ON DELETE CASCADE"`
			}

			// WeightedExercise model
			type WeightedExercise struct {
				HiddenModel
				Sets       int     `json:"sets"`
				Reps       int     `json:"reps"`
				Weight     float32 `json:"weight"`
				ExerciseID uint    `json:"exercise_id" gorm:"type:int REFERENCES exercises(id) ON DELETE CASCADE"`
			}

			// DistanceExercise model
			type DistanceExercise struct {
				HiddenModel
				Time       uint    `json:"time"`
				Distance   float32 `json:"distance"`
				ExerciseID uint    `json:"exercise_id" gorm:"type:int REFERENCES exercises(id) ON DELETE CASCADE"`
			}

			return &gormigrate.Migration{
				ID: migrationID,
				Migrate: func(tx *gorm.DB) error {
					tx = tx.Debug()

					err := tx.AutoMigrate(&ExerciseData{}).Error
					if err != nil {
						return err
					}

					allWeighted := []WeightedExercise{}

					if err := tx.Find(&allWeighted).Error; err != nil {
						return err
					}

					for _, e := range allWeighted {
						data := &ExerciseData{}
						data.Sets = e.Sets
						data.Reps = e.Reps
						data.Weight = e.Weight
						data.ExerciseID = e.ExerciseID

						if err := db.Create(data).Error; err != nil {
							return err
						}
					}

					allDistance := []DistanceExercise{}

					if err := tx.Find(&allDistance).Error; err != nil {
						return err
					}

					for _, e := range allDistance {
						data := &ExerciseData{}
						data.Time = e.Time
						data.Distance = e.Distance
						data.ExerciseID = e.ExerciseID

						if err := db.Create(data).Error; err != nil {
							return err
						}
					}

					return nil
				},
				Rollback: func(tx *gorm.DB) error {
					return tx.DropTableIfExists(&ExerciseData{}).Error
				},
			}
		}),
	})

	m.InitSchema(func(tx *gorm.DB) error {
		err := tx.
			Debug().

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
	})

	return m.Migrate()
}

// Migrate will auto migrate
func MigrateTest(db *gorm.DB) error {
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
