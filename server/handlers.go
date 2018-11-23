package server

import (
	"exercise_parser/models"
	"net/http"
	"strconv"

	"github.com/labstack/echo"
)

func handleGetExercise(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB

	id, err := strconv.Atoi(ctx.Param("id"))

	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	exercise := &models.Exercise{}
	err = db.
		Preload("WeightedExercise").
		Preload("DistanceExercise").
		Where("id = ?", id).
		First(exercise).
		Error

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, exercise)
}

func handlePostExercise(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB

	exercise := &models.Exercise{}

	if err := ctx.Bind(exercise); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	res, err := Resolve(exercise.Raw)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	exercise.Type = res.Type
	exercise.Name = res.Captures["Exercise"]

	if res.Type == "weighted" {
		sets, err := strconv.Atoi(res.Captures["Sets"])
		if err != nil {
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}

		reps, err := strconv.Atoi(res.Captures["Reps"])
		if err != nil {
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}

		weightedExercise := &models.WeightedExercise{
			Sets: sets,
			Reps: reps,
		}

		exercise.WeightedExercise = weightedExercise
	} else if res.Type == "distance" {
		time := res.Captures["Time"]
		units := res.Captures["Units"]

		distance, err := strconv.ParseFloat(res.Captures["Distance"], 32)
		if err != nil {
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}

		distanceExercise := &models.DistanceExercise{
			Time:     time,
			Distance: float32(distance),
			Units:    units,
		}

		exercise.DistanceExercise = distanceExercise
	}

	if err := db.Create(exercise).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, exercise)
}
