package models

import (
	"time"
)

// Workout model
type Workout struct {
	Model
	UserID         uint       `json:"user_id" gorm:"type:int REFERENCES users(id) ON DELETE CASCADE"`
	Name           string     `json:"name"`
	Date           time.Time  `json:"date"`
	Location       *Location  `json:"location"`
	SecondsElapsed uint       `json:"seconds_elapsed"`
	Exercises      []Exercise `json:"exercises"`
	InProgress     *bool      `json:"in_progress"`
}

func (Workout) TableName() string {
	return "workouts"
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
