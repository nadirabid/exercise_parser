package metrics

import (
	"exercise_parser/models"

	"github.com/jinzhu/gorm"
)

func ComputeForWorkout(workoutID uint, db *gorm.DB) error {
	workout := &models.Workout{}
	err := db.
		Preload("Exercises").
		Preload("Exercises.ExerciseData").
		Where("id = ?", workoutID).
		First(workout).
		Error

	if err != nil {
		return err
	}

	dictionaries := []models.ExerciseDictionary{}

	err = db.
		Preload("Muscles").
		Select("DISTINCT ON (exercise_dictionaries.id) exercise_dictionaries.*").
		Joins("JOIN exercises ON exercises.exercise_dictionary_id = exercise_dictionaries.id").
		Joins("JOIN workouts ON workouts.id = exercises.workout_id").
		Where("workouts.id = ?", workoutID).
		Find(&dictionaries).
		Error

	if err != nil {
		return err
	}

	m := computeMetric(workout, dictionaries)

	if err := db.Create(m).Error; err != nil {
		return err
	}

	return err
}

func computeMetric(workout *models.Workout, dictionaries []models.ExerciseDictionary) *models.Metric {
	topLevelMetric := models.MetricTopLevel{}

	repsByExerciseDictionary := map[uint]int{}

	topLevelMetric.SecondsElapsed += workout.SecondsElapsed
	for _, e := range workout.Exercises {
		if e.ExerciseDictionaryID != nil {
			if _, ok := repsByExerciseDictionary[*e.ExerciseDictionaryID]; !ok {
				repsByExerciseDictionary[*e.ExerciseDictionaryID] = 0
			}

			topLevelMetric.Sets += e.ExerciseData.Sets
			topLevelMetric.Reps += e.ExerciseData.Reps * e.ExerciseData.Sets
			topLevelMetric.Distance += e.ExerciseData.Distance
			repsByExerciseDictionary[*e.ExerciseDictionaryID] += e.ExerciseData.Reps * e.ExerciseData.Sets
		}
	}

	repsByTargetMuscles := map[string]int{}
	repsBySynergistMuscles := map[string]int{}
	repsByStabilizerMuscles := map[string]int{}
	repsByDynamicStabilizerMuscles := map[string]int{}
	repsByAntagonistStabilizerMuscles := map[string]int{}
	repsByDynamicArticulationMuscles := map[string]int{}
	repsByStaticArticulationMuscles := map[string]int{}

	// TODO: name standardization should be redudant now that they are standardized in the db
	for _, d := range dictionaries {
		if reps, ok := repsByExerciseDictionary[d.ID]; ok {
			// target
			for _, muscleName := range d.Muscles.Target {
				repsByTargetMuscles[muscleName] += reps
			}

			// synergist
			for _, muscleName := range d.Muscles.Synergists {
				repsBySynergistMuscles[muscleName] += reps
			}

			// stabilizers
			for _, muscleName := range d.Muscles.Stabilizers {
				repsByStabilizerMuscles[muscleName] += reps
			}

			// dynamic stabilizer
			for _, muscleName := range d.Muscles.DynamicStabilizers {
				repsByDynamicStabilizerMuscles[muscleName] += reps
			}

			// antagonist stabilizers
			for _, muscleName := range d.Muscles.AntagonistStabilizers {
				repsByAntagonistStabilizerMuscles[muscleName] += reps
			}

			// dynamic articulation
			for _, muscleName := range d.Muscles.DynamicArticulation {
				repsByDynamicArticulationMuscles[muscleName] += reps
			}

			// static articulation
			for _, muscleName := range d.Muscles.StaticArticulation {
				repsByStaticArticulationMuscles[muscleName] += reps
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

	for muscle, reps := range repsByDynamicArticulationMuscles {
		m := models.MetricMuscle{
			Name:  muscle,
			Reps:  reps,
			Usage: models.DynamicArticulationMuscle,
		}

		metricMuscles = append(metricMuscles, m)
	}

	for muscle, reps := range repsByStaticArticulationMuscles {
		m := models.MetricMuscle{
			Name:  muscle,
			Reps:  reps,
			Usage: models.StaticArticulationMuscle,
		}

		metricMuscles = append(metricMuscles, m)
	}

	return &models.Metric{
		WorkoutID: workout.ID,
		TopLevel:  topLevelMetric,
		Muscles:   metricMuscles,
	}
}
