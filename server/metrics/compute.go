package metrics

import (
	"exercise_parser/calories"
	"exercise_parser/models"

	"github.com/jinzhu/gorm"
)

func ComputeForWorkout(workoutID uint, db *gorm.DB) error {
	workout := &models.Workout{}
	q := db.
		Preload("Exercises").
		Preload("Exercises.ExerciseData").
		Preload("Exercises.ExerciseDictionaries").
		Where("id = ?", workoutID).
		First(workout)

	if err := q.Error; err != nil {
		return err
	}

	user := &models.User{}

	if err := db.First(user).Error; err != nil {
		return err
	}

	dictionaries := []models.ExerciseDictionary{}

	q = db.
		Preload("Muscles").
		Select("DISTINCT ON (exercise_dictionaries.id) exercise_dictionaries.*").
		Joins("JOIN resolved_exercise_dictionaries ON resolved_exercise_dictionaries.exercise_dictionary_id = exercise_dictionaries.id").
		Joins("JOIN exercises ON exercises.id = resolved_exercise_dictionaries.exercise_id").
		Joins("JOIN workouts ON workouts.id = exercises.workout_id").
		Where("workouts.id = ?", workoutID).
		Find(&dictionaries)

	if err := q.Error; err != nil {
		return err
	}

	if err := db.Unscoped().Where("workout_id = ?", workoutID).Delete(&models.Metric{}).Error; err != nil {
		return err
	}

	m, err := computeMetric(user, workout, dictionaries)
	if err != nil {
		return err
	}

	if err := db.Create(m).Error; err != nil {
		return err
	}

	return nil
}

func computeMetric(user *models.User, workout *models.Workout, dictionaries []models.ExerciseDictionary) (*models.Metric, error) {
	topLevelMetric := models.MetricTopLevel{}

	dictionariesByID := make(map[uint]*models.ExerciseDictionary)
	for _, d := range dictionaries {
		dictionariesByID[d.ID] = &d
	}

	calories, err := calories.CalculateFromUserWorkout(user, workout, dictionariesByID)
	if err != nil {
		return nil, err
	}

	topLevelMetric.Calories = calories
	topLevelMetric.SecondsElapsed += workout.SecondsElapsed

	repsByExerciseDictionary := map[uint]int{}
	for _, e := range workout.Exercises {
		circuitRounds := e.CircuitRounds
		if circuitRounds < 1 {
			circuitRounds = 1
		}

		topLevelMetric.Sets += e.ExerciseData.Sets * circuitRounds
		topLevelMetric.Reps += e.ExerciseData.Reps * e.ExerciseData.Sets
		topLevelMetric.Distance += e.ExerciseData.Distance * float64(circuitRounds)

		for _, d := range e.ExerciseDictionaries {
			repsByExerciseDictionary[d.ID] += e.ExerciseData.Reps * e.ExerciseData.Sets * circuitRounds
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
	}, nil
}
