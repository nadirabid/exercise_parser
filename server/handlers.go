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

	if err := db.Where("id = ?", id).First(exercise).Error; err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	if exercise.Type == "weighted" {
		weightedExercise := &models.WeightedExercise{}

		if err := db.Where("id = ?", exercise.WeightedExerciseID).First(weightedExercise).Error; err != nil {
			return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
		}

		exercise.WeightedExercise = weightedExercise
	} else if exercise.Type == "distance" {
		distanceExercise := &models.DistanceExercise{}

		if err := db.Where("id = ?", exercise.DistanceExerciseID).First(distanceExercise).Error; err != nil {
			return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
		}

		exercise.DistanceExercise = distanceExercise
	} else {
		return ctx.JSON(http.StatusNotFound, newErrorMessage("request resource not found"))
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

	db.Create(exercise)

	return ctx.JSON(http.StatusOK, exercise)
}
