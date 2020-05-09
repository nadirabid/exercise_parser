package server

import (
	"exercise_parser/models"
	"net/http"

	"github.com/labstack/echo"
)

type WeeklyMetric struct {
	Distance       float32 `json:"distance"`
	Sets           int     `json:"sets"`
	Reps           int     `json:"reps"`
	SecondsElapsed uint    `json:"seconds_elapsed"`
}

func handleGetWeeklyMetrics(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.db

	userID := getUserIDFromContext(ctx)

	workouts := []models.Workout{}

	err := db.
		Debug(). // TODO: remove
		Preload("Exercises").
		Preload("Exercises.ExerciseData").
		Where("created_at > current_date - INTERVAL '7' day AND user_id = ?", userID).
		Order("created_at desc").
		Find(&workouts).
		Error

	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, err.Error())
	}

	m := WeeklyMetric{}

	for _, w := range workouts {
		m.SecondsElapsed += w.SecondsElapsed

		for _, e := range w.Exercises {
			m.Sets += e.ExerciseData.Sets
			m.Reps += e.ExerciseData.Reps
			m.Distance += e.ExerciseData.Distance
		}
	}

	return ctx.JSON(http.StatusOK, m)
}
