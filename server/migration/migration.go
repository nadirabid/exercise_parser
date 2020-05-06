package migration

import (
	"time"

	"github.com/jinzhu/gorm"
	"github.com/lib/pq"
	"gopkg.in/gormigrate.v1"
)

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

		migration("5-4-2020x2", func(migrationID string) *gormigrate.Migration {
			type Model struct {
				ID        uint       `json:"id" gorm:"primary_key"`
				CreatedAt time.Time  `json:"created_at"`
				UpdatedAt time.Time  `json:"updated_at"`
				DeletedAt *time.Time `json:"-" sql:"index"`
			}

			type ExerciseRelatedName struct {
				Model
				ExerciseDictionaryID uint   `json:"exercise_dictionary_id" gorm:"type:int REFERENCES exercise_dictionaries(id) ON DELETE SET NULL"`
				Related              string `json:"related"`
				RelatedTSV           string `json:"-" gorm:"type:tsvector"`
				Type                 string `json:"type"`
				Ignored              bool   `json:"ignored"`
			}

			return &gormigrate.Migration{
				ID: migrationID,
				Migrate: func(tx *gorm.DB) error {
					if err := tx.AutoMigrate(&ExerciseRelatedName{}).Error; err != nil {
						return err
					}

					if err := tx.Exec("ALTER TABLE exercise_related_names DROP CONSTRAINT IF EXISTS exercise_related_names_pkey").Error; err != nil {
						return err
					}

					if err := tx.Exec("ALTER TABLE exercise_related_names ADD PRIMARY KEY (id)").Error; err != nil {
						return err
					}

					return nil
				},
				Rollback: func(tx *gorm.DB) error {
					return nil
				},
			}
		}),
	})

	m.InitSchema(func(tx *gorm.DB) error {
		type Model struct {
			ID        uint       `json:"id" gorm:"primary_key"`
			CreatedAt time.Time  `json:"created_at"`
			UpdatedAt time.Time  `json:"updated_at"`
			DeletedAt *time.Time `json:"-" sql:"index"`
		}

		type HiddenModel struct {
			ID        uint       `json:"-" gorm:"primary_key"`
			CreatedAt time.Time  `json:"-"`
			UpdatedAt time.Time  `json:"-"`
			DeletedAt *time.Time `json:"-" sql:"index"`
		}

		type User struct {
			Model
			GivenName      string `json:"given_name"`
			FamilyName     string `json:"family_name"`
			Email          string `json:"email"`
			ExternalUserId string `json:"external_user_id" gorm:"unique_index:ext_id; not null"` // this comes externally, in the case of apple - this is their stable id
		}

		type WeightedExercise struct {
			HiddenModel
			Sets       int     `json:"sets"`
			Reps       int     `json:"reps"`
			Weight     float32 `json:"weight"`
			ExerciseID uint    `json:"exercise_id" gorm:"type:int REFERENCES exercises(id) ON DELETE CASCADE"`
		}

		type DistanceExercise struct {
			HiddenModel
			Time       uint    `json:"time"`
			Distance   float32 `json:"distance"`
			ExerciseID uint    `json:"exercise_id" gorm:"type:int REFERENCES exercises(id) ON DELETE CASCADE"`
		}

		type Exercise struct {
			Model
			Raw                  string            `json:"raw"`
			Type                 string            `json:"type"`
			ResolutionType       string            `json:"resolution_type"`
			Name                 string            `json:"name"`
			ExerciseDictionaryID *uint             `json:"exercise_dictionary_id" gorm:"type:int REFERENCES exercise_dictionaries(id) ON DELETE SET NULL"`
			WeightedExercise     *WeightedExercise `json:"weighted_exercise"`
			DistanceExercise     *DistanceExercise `json:"distance_exercise"`
			WorkoutID            uint              `json:"workout_id" gorm:"type:int REFERENCES workouts(id) ON DELETE CASCADE"`
		}

		type Location struct {
			Model
			Latitude  float64 `json:"latitude" gorm:"not null"`
			Longitude float64 `json:"longitude" gorm:"not null"`
			WorkoutID uint    `json:"workout_id" gorm:"type:int REFERENCES workouts(id) ON DELETE CASCADE"`
		}

		type Workout struct {
			Model
			Name           string     `json:"name"`
			Date           time.Time  `json:"date"`
			Exercises      []Exercise `json:"exercises"`
			Location       *Location  `json:"location"`
			SecondsElapsed uint       `json:"seconds_elapsed"`
			UserID         uint       `json:"user_id" gorm:"type:int REFERENCES users(id) ON DELETE CASCADE"`
		}

		type Classification struct {
			HiddenModel
			Utility              string `json:"utility"`
			Mechanics            string `json:"mechanics"`
			Force                string `json:"force"`
			Intensity            string `json:"intensity"`
			Function             string `json:"function"`
			Bearing              string `json:"bearing"`
			Impact               string `json:"impact"`
			ExerciseDictionaryID uint   `json:"exercise_dictionary_id" gorm:"type:int REFERENCES exercise_dictionaries(id) ON DELETE CASCADE"`
		}

		type Muscles struct {
			HiddenModel
			Target                pq.StringArray `json:"target" gorm:"type:varchar(250)[]"`
			Synergists            pq.StringArray `json:"synergists" gorm:"type:varchar(250)[]"`
			Stabilizers           pq.StringArray `json:"stabilizers" gorm:"type:varchar(250)[]"`
			DynamicStabilizers    pq.StringArray `json:"dynamic_stabilizers" gorm:"type:varchar(250)[]"`
			AntagonistStabilizers pq.StringArray `json:"antagonist_stabilizers" gorm:"type:varchar(250)[]"`
			ROMCriteria           pq.StringArray `json:"rom_criteria" gorm:"type:varchar(250)[]"`
			ExerciseDictionaryID  uint           `json:"exercise_dictionary_id" gorm:"type:int REFERENCES exercise_dictionaries(id) ON DELETE CASCADE"`
		}

		type Joints struct {
			HiddenModel
			Ankle          pq.StringArray `json:"ankle" gorm:"type:varchar(250)[]"`
			Elbow          pq.StringArray `json:"elbow" gorm:"type:varchar(250)[]"`
			Finger         pq.StringArray `json:"finger" gorm:"type:varchar(250)[]"`
			Foot           pq.StringArray `json:"foot" gorm:"type:varchar(250)[]"`
			Forearms       pq.StringArray `json:"forearms" gorm:"type:varchar(250)[]"`
			Hip            pq.StringArray `json:"hip" gorm:"type:varchar(250)[]"`
			Scapula        pq.StringArray `json:"scapula" gorm:"type:varchar(250)[]"`
			Clavicle       pq.StringArray `json:"clavicle" gorm:"type:varchar(250)[]"`
			Shoulder       pq.StringArray `json:"shoulder" gorm:"type:varchar(250)[]"`
			ShoulderGirdle pq.StringArray `json:"shoulder_girdle" gorm:"type:varchar(250)[]"`
			Spine          pq.StringArray `json:"spine" gorm:"type:varchar(250)[]"`
			Thumb          pq.StringArray `json:"thumb" gorm:"type:varchar(250)[]"`
			Wrist          pq.StringArray `json:"wrist" gorm:"type:varchar(250)[]"`
			Knee           pq.StringArray `json:"knee" gorm:"type:varchar(250)[]"`
			ArticulationID int            `json:"articulation_id" gorm:"type:int REFERENCES articulations(id) ON DELETE CASCADE"`
		}

		type Articulation struct {
			HiddenModel
			Dynamic              Joints `json:"dynamic"`
			Static               Joints `json:"static"`
			ExerciseDictionaryID uint   `json:"exercise_dictionary_id" gorm:"type:int REFERENCES exercise_dictionaries(id) ON DELETE CASCADE"`
		}

		type ExerciseRelatedName struct {
			ID                   uint   `json:"id" gorm:"primary_key"`
			ExerciseDictionaryID uint   `json:"exercise_dictionary_id" gorm:"type:int REFERENCES exercise_dictionaries(id) ON DELETE SET NULL"`
			Related              string `json:"related" gorm:"unique"`
			RelatedTSV           string `json:"-" gorm:"type:tsvector"`
			Type                 string `json:"type"`
			Ignored              bool   `json:"ignored"`
		}

		type ExerciseDictionary struct {
			Model
			URL            string         `json:"url"`
			Name           string         `json:"name" gorm:"unique"`
			Classification Classification `json:"classification"`
			Muscles        Muscles        `json:"muscles"`
			Articulation   Articulation   `json:"articulation"`
			TSV            string         `json:"-" gorm:"type:tsvector"`
		}

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
