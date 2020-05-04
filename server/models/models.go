package models

import (
	"exercise_parser/parser"
	"exercise_parser/utils"
	"fmt"
	"strconv"
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
		sets, err := strconv.Atoi(res.Captures["Sets"])
		if err != nil {
			sets = 1
		}

		reps, err := strconv.Atoi(res.Captures["Reps"])
		if err != nil {
			return err
		}

		if e.WeightedExercise == nil {
			e.WeightedExercise = &WeightedExercise{}
		}

		e.WeightedExercise.Sets = sets
		e.WeightedExercise.Reps = reps

		if weightStr, ok := res.Captures["Weight"]; ok {
			unit := utils.GetStringOrDefault(res.Captures["Units"], "pounds")

			weight, err := strconv.ParseFloat(weightStr, 32)
			if err != nil {
				return err
			}

			standardized, err := parser.UnitStandardize(unit, float32(weight))
			if err != nil {
				return err
			}

			e.WeightedExercise.Weight = standardized
		}
	} else if res.Type == "distance" {
		unit := utils.GetStringOrDefault(res.Captures["Units"], "miles")

		distance, err := strconv.ParseFloat(res.Captures["Distance"], 32)
		if err != nil {
			return err
		}

		if e.DistanceExercise == nil {
			e.DistanceExercise = &DistanceExercise{}
		}

		standardizedDist, err := parser.UnitStandardize(unit, float32(distance))
		if err != nil {
			return nil
		}
		e.DistanceExercise.Distance = standardizedDist

		if timeStr, ok := res.Captures["Time"]; ok {
			timeUnit := utils.GetStringOrDefault(res.Captures["TimeUnits"], "minutes")

			time, err := strconv.ParseFloat(timeStr, 32)
			if err != nil {
				return err
			}

			standardizedTime, err := parser.UnitStandardize(timeUnit, float32(time))
			if err != nil {
				return err
			}

			e.DistanceExercise.Time = uint(standardizedTime)
		}
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
