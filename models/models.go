package models

import (
	"exercise_parser/parser"
	"fmt"
	"strconv"
	"time"

	"github.com/jinzhu/gorm"
)

// Workout model
type Workout struct {
	gorm.Model
	Name      string     `json:"name"`
	Date      time.Time  `json:"date"`
	Exercises []Exercise `json:"exercises"`
}

// Exercise model
type Exercise struct {
	gorm.Model
	Raw              string            `json:"raw"`
	Type             string            `json:"type"`
	Name             string            `json:"name"`
	WeightedExercise *WeightedExercise `json:"weighted_exercise"`
	DistanceExercise *DistanceExercise `json:"distance_exercise"`
	WorkoutID        int               `json:"workout_id"`
}

// Resolve will take the Raw exercise string and parse out the various fields
func (e *Exercise) Resolve() error {
	res, err := parser.Resolve(e.Raw)
	if err != nil {
		return err
	}

	e.Type = res.Type
	e.Name = res.Captures["Exercise"]

	if res.Type == "weighted" {
		sets, err := strconv.Atoi(res.Captures["Sets"])
		if err != nil {
			return err
		}

		reps, err := strconv.Atoi(res.Captures["Reps"])
		if err != nil {
			return err
		}

		weightedExercise := &WeightedExercise{
			Sets: sets,
			Reps: reps,
		}

		e.WeightedExercise = weightedExercise
	} else if res.Type == "distance" {
		time := res.Captures["Time"]
		units := res.Captures["Units"]

		distance, err := strconv.ParseFloat(res.Captures["Distance"], 32)
		if err != nil {
			return err
		}

		distanceExercise := &DistanceExercise{
			Time:     time,
			Distance: float32(distance),
			Units:    units,
		}

		e.DistanceExercise = distanceExercise
	} else {
		return fmt.Errorf("unable to resolve raw expression: %v", e)
	}

	return nil
}

// WeightedExercise model
type WeightedExercise struct {
	gorm.Model
	Sets       int `json:"sets"`
	Reps       int `json:"reps"`
	ExerciseID int `json:"exercise_id"`
}

// DistanceExercise model
type DistanceExercise struct {
	gorm.Model
	Time       string  `json:"time"`
	Distance   float32 `json:"distance"`
	Units      string  `json:"units"`
	ExerciseID int     `json:"exercise_id"`
}
