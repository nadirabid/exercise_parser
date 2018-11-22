package models

import kallax "gopkg.in/src-d/go-kallax.v1"

//go:generate kallax gen

// Exercise model
type Exercise struct {
	kallax.Model `table:"exercises" pk:"id,autoincr"`
	ID           int64
	Raw          string `json:"raw"`
}

// WeightedExercise model
type WeightedExercise struct {
	kallax.Model `table:"weighted_exercises" pk:"id"`
	ID           int64
	Exercise     string
	Sets         int
	Reps         int
}

// DistanceExercise model
type DistanceExercise struct {
	kallax.Model `tabel:"distance_exercises" pk:"id"`
	ID           int64
	Exercise     string
	Time         string
	Distance     float32
	Units        float32
}
