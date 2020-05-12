package metrics

import (
	"exercise_parser/models"
	"exercise_parser/utils"
	"fmt"

	"github.com/jinzhu/gorm"
)

func ComputeForWorkout(workoutID uint, db *gorm.DB) {
	fmt.Printf("Compute for workout: %s\n", workoutID)

	workout := &models.Workout{}
	err := db.
		Preload("Exercises").
		Preload("Exercises.ExerciseData").
		Where("id = ?", workoutID).
		First(workout).
		Error

	if err != nil {
		fmt.Printf("Error: %s", err.Error())
		return
	}

	dictionaries := []models.ExerciseDictionary{}

	err = db.
		Preload("Muscles").
		Select("DISTINCT ON (id) exercise_dictionaries.*").
		Joins("JOIN exercises ON exercises.exercise_dictionary_id = exercise_dictionaries.id").
		Joins("JOIN workouts ON workouts.id = exercises.workout_id").
		Where("workouts.id = ?", workoutID).
		Find(&dictionaries).
		Error

	if err != nil {
		fmt.Printf("Error: %s\n", err.Error())
		return
	}

	m := computeMetric(workout, dictionaries)

	utils.PrettyPrint(m)

	if err := db.Debug().Create(m).Error; err != nil {
		fmt.Printf("Error: %s\n", err.Error())
	}

	fmt.Printf("Compute completed for workout: %s\n", workoutID)
}

func computeMetric(workout *models.Workout, dictionaries []models.ExerciseDictionary) *models.Metric {
	topLevelMetric := models.MetricTopLevel{}

	repsByDictionary := map[uint]int{}

	for _, e := range workout.Exercises {
		if e.ExerciseDictionaryID != nil {
			if _, ok := repsByDictionary[*e.ExerciseDictionaryID]; !ok {
				repsByDictionary[*e.ExerciseDictionaryID] = 0
			}

			topLevelMetric.Sets += e.ExerciseData.Sets
			topLevelMetric.Reps += e.ExerciseData.Reps
			topLevelMetric.Distance += e.ExerciseData.Distance
			repsByDictionary[*e.ExerciseDictionaryID] += e.ExerciseData.Sets
		}
	}

	repsByTargetMuscles := map[string]int{}
	repsBySynergistMuscles := map[string]int{}
	repsByStabilizerMuscles := map[string]int{}
	repsByDynamicStabilizerMuscles := map[string]int{}
	repsByAntagonistStabilizerMuscles := map[string]int{}

	for _, d := range dictionaries {
		if reps, ok := repsByDictionary[d.ID]; ok {
			// target
			for _, muscleName := range d.Muscles.Target {
				standardMuscleName, err := models.MuscleStandardName(muscleName)
				if err != nil {
					fmt.Printf("Error: unknown muscle: %s\n", muscleName)
					continue
				}

				if _, ok := repsByTargetMuscles[standardMuscleName]; !ok {
					repsByTargetMuscles[standardMuscleName] = 0
				}

				repsByTargetMuscles[standardMuscleName] += reps
			}

			// synergist
			for _, muscleName := range d.Muscles.Synergists {
				standardMuscleName, err := models.MuscleStandardName(muscleName)
				if err != nil {
					fmt.Printf("Error: unknown muscle: %s\n", muscleName)
					continue
				}

				if _, ok := repsBySynergistMuscles[standardMuscleName]; !ok {
					repsBySynergistMuscles[standardMuscleName] = 0
				}

				repsBySynergistMuscles[standardMuscleName] += reps
			}

			// stabilizers
			for _, muscleName := range d.Muscles.Stabilizers {
				standardMuscleName, err := models.MuscleStandardName(muscleName)
				if err != nil {
					fmt.Printf("Error: unknown muscle: %s\n", muscleName)
					continue
				}

				if _, ok := repsByStabilizerMuscles[standardMuscleName]; !ok {
					repsByStabilizerMuscles[standardMuscleName] = 0
				}

				repsByStabilizerMuscles[standardMuscleName] += reps
			}

			// dynamic stabilizer
			for _, muscleName := range d.Muscles.DynamicStabilizers {
				standardMuscleName, err := models.MuscleStandardName(muscleName)
				if err != nil {
					fmt.Printf("Error: unknown muscle: %s\n", muscleName)
					continue
				}

				if _, ok := repsByDynamicStabilizerMuscles[standardMuscleName]; !ok {
					repsByDynamicStabilizerMuscles[standardMuscleName] = 0
				}

				repsByDynamicStabilizerMuscles[standardMuscleName] += reps
			}

			// antagonist stabilizers
			for _, muscleName := range d.Muscles.AntagonistStabilizers {
				standardMuscleName, err := models.MuscleStandardName(muscleName)
				if err != nil {
					fmt.Printf("Error: unknown muscle: %s\n", muscleName)
					continue
				}

				if _, ok := repsByAntagonistStabilizerMuscles[standardMuscleName]; !ok {
					repsByAntagonistStabilizerMuscles[standardMuscleName] = 0
				}

				repsByAntagonistStabilizerMuscles[standardMuscleName] += reps
			}
		}
	}

	metricMuscles := []models.MetricMuscle{}

	for muscle, reps := range repsByTargetMuscles {
		m := models.MetricMuscle{
			Name:  muscle,
			Reps:  reps,
			Usage: models.TargetMuscle,
		}

		metricMuscles = append(metricMuscles, m)
	}

	for muscle, reps := range repsBySynergistMuscles {
		m := models.MetricMuscle{
			Name:  muscle,
			Reps:  reps,
			Usage: models.SynergistMuscle,
		}

		metricMuscles = append(metricMuscles, m)
	}

	for muscle, reps := range repsByStabilizerMuscles {
		m := models.MetricMuscle{
			Name:  muscle,
			Reps:  reps,
			Usage: models.StabilizerMuscle,
		}

		metricMuscles = append(metricMuscles, m)
	}

	for muscle, reps := range repsByDynamicStabilizerMuscles {
		m := models.MetricMuscle{
			Name:  muscle,
			Reps:  reps,
			Usage: models.DynamicStabilizerMuscle,
		}

		metricMuscles = append(metricMuscles, m)
	}

	for muscle, reps := range repsByAntagonistStabilizerMuscles {
		m := models.MetricMuscle{
			Name:  muscle,
			Reps:  reps,
			Usage: models.AntagonistStabilizerMuscle,
		}

		metricMuscles = append(metricMuscles, m)
	}

	return &models.Metric{
		WorkoutID: workout.ID,
		TopLevel:  topLevelMetric,
		Muscles:   metricMuscles,
	}
}
