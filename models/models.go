package models

import (
	"exercise_parser/parser"
	"fmt"
	"strconv"
	"time"
)

// Model contains the common properties between all models
type Model struct {
	ID        uint       `json:"id" gorm:"primary_key"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `json:"-" sql:"index"`
}

// HiddenModel contains common properties with hidden json properties
type HiddenModel struct {
	ID        uint       `json:"-" gorm:"primary_key"`
	CreatedAt time.Time  `json:"-"`
	UpdatedAt time.Time  `json:"-"`
	DeletedAt *time.Time `json:"-" sql:"index"`
}

// Workout model
type Workout struct {
	Model
	Name      string     `json:"name"`
	Date      time.Time  `json:"date"`
	Exercises []Exercise `json:"exercises"`
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

// Exercise model
type Exercise struct {
	Model
	Raw              string            `json:"raw"`
	Type             string            `json:"type"`
	Name             string            `json:"name"`
	WeightedExercise *WeightedExercise `json:"weighted_exercise"`
	DistanceExercise *DistanceExercise `json:"distance_exercise"`
	WorkoutID        int               `json:"workout_id"`
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
			return err
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
	} else if res.Type == "distance" {
		time := res.Captures["Time"]
		units := res.Captures["Units"]

		distance, err := strconv.ParseFloat(res.Captures["Distance"], 32)
		if err != nil {
			return err
		}

		if e.DistanceExercise == nil {
			e.DistanceExercise = &DistanceExercise{}
		}

		e.DistanceExercise.Time = time
		e.DistanceExercise.Distance = float32(distance)
		e.DistanceExercise.Units = units
	} else {
		return fmt.Errorf("unable to resolve raw expression: %v", e)
	}

	return nil
}

// WeightedExercise model
type WeightedExercise struct {
	HiddenModel
	Sets       int `json:"sets"`
	Reps       int `json:"reps"`
	ExerciseID int `json:"exercise_id"`
}

// DistanceExercise model
type DistanceExercise struct {
	HiddenModel
	Time       string  `json:"time"`
	Distance   float32 `json:"distance"`
	Units      string  `json:"units"`
	ExerciseID int     `json:"exercise_id"`
}