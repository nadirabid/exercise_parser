package models

import (
	"exercise_parser/parser"
	"exercise_parser/utils"
	"fmt"
	"strconv"
	"strings"
	"time"
)

// Workout model
type Workout struct {
	Model
	Name           string     `json:"name"`
	Date           time.Time  `json:"date"`
	Exercises      []Exercise `json:"exercises"`
	Location       *Location  `json:"location"`
	SecondsElapsed uint       `json:"seconds_elapsed"`
	UserID         uint       `json:"user_id" gorm:"type:int REFERENCES users(id) ON DELETE CASCADE"`
}

// HasExercise returns true if Exercise exists with id, otherwise false
func (w *Workout) HasExercise(id uint) bool {
	for _, e := range w.Exercises {
		if e.ID == id {
			return true
		}
	}

	return false
}

type Location struct {
	Model
	Latitude  float64 `json:"latitude" gorm:"not null"`
	Longitude float64 `json:"longitude" gorm:"not null"`
	WorkoutID uint    `json:"workout_id" gorm:"type:int REFERENCES workouts(id) ON DELETE CASCADE"`
}

// Exercise model
type Exercise struct {
	Model
	Raw                  string            `json:"raw"`
	Type                 string            `json:"type"`
	ResolutionType       string            `json:"resolution_type"`
	Name                 string            `json:"name"`
	ExerciseDictionaryID *uint             `json:"exercise_dictionary_id" gorm:"type:int REFERENCES exercise_dictionaries(id) ON DELETE SET NULL"`
	ExerciseData         ExerciseData      `json:"data"`
	WeightedExercise     *WeightedExercise `json:"weighted_exercise"`
	DistanceExercise     *DistanceExercise `json:"distance_exercise"`
	WorkoutID            uint              `json:"workout_id" gorm:"type:int REFERENCES workouts(id) ON DELETE CASCADE"`
}

// Resolve will take the Raw exercise string and parse out the various fields
func (e *Exercise) Resolve() error {
	res, err := parser.Get().Resolve(e.Raw)
	if err != nil {
		return err
	}

	e.Type = res.Type
	e.Name = res.Captures["Exercise"]

	if res.Type == "weighted" {
		sets, err := evalSets(res.Captures)
		if err != nil {
			return err
		}

		reps, err := evalReps(res.Captures)
		if err != nil {
			return err
		}

		weight, err := evalWeight(res.Captures)
		if err != nil {
			return err
		}

		if e.WeightedExercise == nil {
			e.WeightedExercise = &WeightedExercise{}
		}

		e.WeightedExercise.Sets = sets
		e.WeightedExercise.Reps = reps
		e.WeightedExercise.Weight = weight
	} else if res.Type == "distance" {
		distance, err := evalDistance(res.Captures)
		if err != nil {
			return err
		}

		time, err := evalTime(res.Captures)
		if err != nil {
			return err
		}

		if e.DistanceExercise == nil {
			e.DistanceExercise = &DistanceExercise{}
		}

		e.DistanceExercise.Distance = distance
		e.DistanceExercise.Time = time
	} else {
		return fmt.Errorf("unable to resolve raw expression: %v", e)
	}

	e.ResolutionType = "auto"

	return nil
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

// returns 1 if not specified
func evalSets(captures map[string]string) (int, error) {
	sets, err := strconv.Atoi(captures["Sets"])
	if err != nil {
		sets = 1
	}

	return sets, nil
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

// returns err if not specified
func evalReps(captures map[string]string) (int, error) {
	repStr := captures["Reps"]
	if strings.Contains(repStr, "-") {
		repTokens := strings.Split(repStr, "-")
		if len(repTokens) != 2 {
			return 0, fmt.Errorf("Reps contains -, but doesn't have two rep numbers. Eg of expected: 10-12")
		}

		reps1, err := strconv.Atoi(repTokens[0])
		reps2, err := strconv.Atoi(repTokens[1])

		if err != nil {
			return 0, err
		}

		return utils.MaxInt(reps1, reps2), nil
	}

	reps, err := strconv.Atoi(repStr)
	if err != nil {
		return 0, err
	}
	return reps, nil
}

// returns 0 if not specified
func evalWeight(captures map[string]string) (float32, error) {
	weightStr, ok := captures["Weight"]
	if !ok {
		return 0, nil
	}

	unit := utils.GetStringOrDefault(captures["Units"], "pounds")

	weight, err := strconv.ParseFloat(weightStr, 32)
	if err != nil {
		return 0, err
	}

	standardized, err := parser.UnitStandardize(unit, float32(weight))
	if err != nil {
		return 0, err
	}

	return standardized, nil
}

// returns 0 if not specified
func evalTime(captures map[string]string) (uint, error) {
	timeStr, ok := captures["Time"]

	if !ok {
		return 0, nil
	}

	timeUnit := utils.GetStringOrDefault(captures["TimeUnits"], "minutes")

	time, err := strconv.ParseFloat(timeStr, 32)
	if err != nil {
		return 0, err
	}

	standardizedTime, err := parser.UnitStandardize(timeUnit, float32(time))
	if err != nil {
		return 0, err
	}

	return uint(standardizedTime), nil
}

// returns error if not specified
func evalDistance(captures map[string]string) (float32, error) {
	unit := utils.GetStringOrDefault(captures["Units"], "miles")

	distance, err := strconv.ParseFloat(captures["Distance"], 32)
	if err != nil {
		return 0, err
	}

	standardizedDist, err := parser.UnitStandardize(unit, float32(distance))
	if err != nil {
		return 0, err
	}

	return standardizedDist, nil
}
