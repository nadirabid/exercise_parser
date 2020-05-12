package server

import (
	"exercise_parser/models"
	"exercise_parser/utils"
	"fmt"
	"net/http"
	"strconv"

	"github.com/labstack/echo"
)

type MuscleStat struct {
	Muscle string `json:"muscle"`
	Reps   int    `json:"reps"`
}

type WeeklyMetric struct {
	TargetMuscles               []MuscleStat `json:"target_muscles"`
	SynergistMuscles            []MuscleStat `json:"synergist_muscles"`
	StabilizerMuscles           []MuscleStat `json:"stabilizer_muscles"`
	DynamicStabilizerMuscles    []MuscleStat `json:"dynamic_stabilizer_muscles"`
	AntagonistStabilizerMuscles []MuscleStat `json:"antagonist_stabilizer_muscles"`
	Distance                    float32      `json:"distance"`
	Sets                        int          `json:"sets"`
	Reps                        int          `json:"reps"`
	SecondsElapsed              uint         `json:"seconds_elapsed"`
}

func handleGetWeeklyMetrics(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.db

	userID := getUserIDFromContext(ctx)

	workouts := []models.Workout{}

	err := db.
		Preload("Exercises").
		Preload("Exercises.ExerciseData").
		Where("created_at > current_date - INTERVAL '7' day AND user_id = ?", userID).
		Order("created_at desc").
		Find(&workouts).
		Error

	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, err.Error())
	}

	dictionaries := []models.ExerciseDictionary{}

	err = db.
		Preload("Muscles").
		Select("DISTINCT ON (id) exercise_dictionaries.*").
		Joins("JOIN exercises ON exercises.exercise_dictionary_id = exercise_dictionaries.id").
		Joins("JOIN workouts ON workouts.id = exercises.workout_id").
		Where("workouts.created_at > current_date - INTERVAL '7' day AND user_id = ?", userID).
		Find(&dictionaries).
		Error

	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, err.Error())
	}

	weekly := WeeklyMetric{
		TargetMuscles:               []MuscleStat{},
		SynergistMuscles:            []MuscleStat{},
		StabilizerMuscles:           []MuscleStat{},
		DynamicStabilizerMuscles:    []MuscleStat{},
		AntagonistStabilizerMuscles: []MuscleStat{},
	}
	repsByDictionary := map[uint]int{}

	for _, w := range workouts {
		weekly.SecondsElapsed += w.SecondsElapsed

		for _, e := range w.Exercises {
			if e.ExerciseDictionaryID != nil {
				if _, ok := repsByDictionary[*e.ExerciseDictionaryID]; !ok {
					repsByDictionary[*e.ExerciseDictionaryID] = 0
				}

				weekly.Sets += e.ExerciseData.Sets
				weekly.Reps += e.ExerciseData.Reps
				weekly.Distance += e.ExerciseData.Distance
				repsByDictionary[*e.ExerciseDictionaryID] += e.ExerciseData.Sets
			}
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

	for muscle, reps := range repsByTargetMuscles {
		m := MuscleStat{
			Muscle: muscle,
			Reps:   reps,
		}

		weekly.TargetMuscles = append(weekly.TargetMuscles, m)
	}

	for muscle, reps := range repsBySynergistMuscles {
		m := MuscleStat{
			Muscle: muscle,
			Reps:   reps,
		}

		weekly.SynergistMuscles = append(weekly.SynergistMuscles, m)
	}

	for muscle, reps := range repsByStabilizerMuscles {
		m := MuscleStat{
			Muscle: muscle,
			Reps:   reps,
		}

		weekly.StabilizerMuscles = append(weekly.StabilizerMuscles, m)
	}

	for muscle, reps := range repsByDynamicStabilizerMuscles {
		m := MuscleStat{
			Muscle: muscle,
			Reps:   reps,
		}

		weekly.DynamicStabilizerMuscles = append(weekly.DynamicStabilizerMuscles, m)
	}

	for muscle, reps := range repsByAntagonistStabilizerMuscles {
		m := MuscleStat{
			Muscle: muscle,
			Reps:   reps,
		}

		weekly.AntagonistStabilizerMuscles = append(weekly.AntagonistStabilizerMuscles, m)
	}

	return ctx.JSON(http.StatusOK, weekly)
}

func handleGetMetrics(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.db

	pastDays, err := strconv.Atoi(utils.GetStringOrDefault(ctx.QueryParam("pastDays"), "7"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	if pastDays > 90 {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	userID := getUserIDFromContext(ctx)

	metrics := []models.Metric{}

	err = db.Debug().
		Preload("Muscles").
		Preload("TopLevel").
		Joins("JOIN workouts ON workouts.id = metrics.workout_id").
		Where("workouts.created_at > current_date - INTERVAL ? day AND user_id = ?", pastDays, userID).
		Find(&metrics).
		Error

	response := models.Metric{
		Muscles: []models.MetricMuscle{},
	}

	repsByTargetMuscles := map[string]int{}
	repsBySynergistMuscles := map[string]int{}
	repsByStabilizerMuscles := map[string]int{}
	repsByDynamicStabilizerMuscles := map[string]int{}
	repsByAntagonistStabilizerMuscles := map[string]int{}

	for _, metric := range metrics {
		response.TopLevel.Sets += metric.TopLevel.Sets
		response.TopLevel.Reps += metric.TopLevel.Reps
		response.TopLevel.Distance += metric.TopLevel.Distance
		response.TopLevel.SecondsElapsed += metric.TopLevel.SecondsElapsed

		for _, muscle := range metric.Muscles {
			switch muscle.Usage {
			case models.TargetMuscle:
				repsByTargetMuscles[muscle.Name] += muscle.Reps
			case models.SynergistMuscle:
				repsBySynergistMuscles[muscle.Name] += muscle.Reps
			case models.StabilizerMuscle:
				repsByStabilizerMuscles[muscle.Name] += muscle.Reps
			case models.DynamicStabilizerMuscle:
				repsByDynamicStabilizerMuscles[muscle.Name] += muscle.Reps
			case models.AntagonistStabilizerMuscle:
				repsByAntagonistStabilizerMuscles[muscle.Name] += muscle.Reps
			}
		}
	}

	for name, reps := range repsByTargetMuscles {
		response.Muscles = append(response.Muscles, models.MetricMuscle{
			Name:  name,
			Reps:  reps,
			Usage: models.TargetMuscle,
		})
	}

	for name, reps := range repsBySynergistMuscles {
		response.Muscles = append(response.Muscles, models.MetricMuscle{
			Name:  name,
			Reps:  reps,
			Usage: models.SynergistMuscle,
		})
	}

	for name, reps := range repsByStabilizerMuscles {
		response.Muscles = append(response.Muscles, models.MetricMuscle{
			Name:  name,
			Reps:  reps,
			Usage: models.StabilizerMuscle,
		})
	}

	for name, reps := range repsByDynamicStabilizerMuscles {
		response.Muscles = append(response.Muscles, models.MetricMuscle{
			Name:  name,
			Reps:  reps,
			Usage: models.DynamicStabilizerMuscle,
		})
	}

	for name, reps := range repsByAntagonistStabilizerMuscles {
		response.Muscles = append(response.Muscles, models.MetricMuscle{
			Name:  name,
			Reps:  reps,
			Usage: models.AntagonistStabilizerMuscle,
		})
	}

	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, metrics)
}
