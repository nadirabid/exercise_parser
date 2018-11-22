package models

import (
	"github.com/jinzhu/gorm"
)

//go:generate kallax gen

// // Workout model
// type Workout struct {
// 	kallax.Model `table:"workouts" pk:"id,autoincr"`
// 	ID           int64       `json:"id"`
// 	Name string `json:"name"`
// 	Exercises    []*Exercise `json:"exercises"`
// }

// Exercise model
type Exercise struct {
	gorm.Model
	Raw                string            `json:"raw"`
	Type               string            `json:"type"`
	Name               string            `json:"name"`
	WeightedExercise   *WeightedExercise `json:"weighted_exercise" gorm:"foreignkey:WeightedExerciseID"`
	DistanceExercise   *DistanceExercise `json:"distance_exercise" gorm:"foreignkey:DistanceExerciseID"`
	WeightedExerciseID *int              `json:"weighted_exercise_id"`
	DistanceExerciseID *int              `json:"distance_exercise_id"`
}

// WeightedExercise model
type WeightedExercise struct {
	gorm.Model
	Sets int `json:"sets"`
	Reps int `json:"reps"`
}

// DistanceExercise model
type DistanceExercise struct {
	gorm.Model
	Time     string  `json:"time"`
	Distance float32 `json:"distannce"`
	Units    string  `json:"units"`
}
