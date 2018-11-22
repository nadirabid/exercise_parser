package models

import kallax "gopkg.in/src-d/go-kallax.v1"

//go:generate kallax gen

// Exercise model
type Exercise struct {
	kallax.Model `table:"exercises" pk:"id,autoincr"`
	ID           int64  `json:"id"`
	Raw          string `json:"raw"`
	Type         string `json:"type"`
	Name         string `json:"name"`
}

// WeightedExercise model
type WeightedExercise struct {
	kallax.Model `table:"weighted_exercises" pk:"id,autoincr"`
	ID           int64    `json:"id"`
	Sets         int      `json:"sets"`
	Reps         int      `json:"reps"`
	Exercise     Exercise `json:"exercise" fk:",inverse"`
}

// DistanceExercise model
type DistanceExercise struct {
	kallax.Model `tabel:"distance_exercises" pk:"id,autoincr"`
	ID           int64
	Time         string   `json:"time"`
	Distance     float32  `json:"distannce"`
	Units        string   `json:"units"`
	Exercise     Exercise `json:"exercise" fk:",inverse"`
}
