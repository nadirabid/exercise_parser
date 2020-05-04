package server

import (
	"exercise_parser/models"
	"exercise_parser/utils"
	"fmt"
	"net/http"
	"strconv"

	"github.com/labstack/echo"
)

func handleGetWorkout(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	userID := getUserIDFromContext(ctx)

	workout := &models.Workout{}
	err = db.
		Preload("Exercises").
		Preload("Exercises.WeightedExercise").
		Preload("Exercises.DistanceExercise").
		Where("id = ?", id).
		Where("user_id = ?", userID).
		First(workout).
		Error

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, workout)
}

func handleGetAllWorkout(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	workouts := []models.Workout{}

	page, err := strconv.Atoi(utils.GetStringOrDefault(ctx.QueryParam("page"), "0"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	size, err := strconv.Atoi(utils.GetStringOrDefault(ctx.QueryParam("size"), "20"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	userID := getUserIDFromContext(ctx)

	q := db.
		Preload("Location").
		Preload("Exercises").
		Preload("Exercises.WeightedExercise").
		Preload("Exercises.DistanceExercise").
		Where("user_id = ?", userID).
		Order("created_at desc")

	listResponse, err := paging(q, page, size, &workouts)

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, listResponse)
}

func handlePostWorkout(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	userID := getUserIDFromContext(ctx)

	workout := &models.Workout{}

	if err := ctx.Bind(workout); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	workout.UserID = userID // to make sure user isn't overriding this value

	for i, e := range workout.Exercises {
		// we stage in two different phases:
		// 1. parse the user exercise string into parts
		// 2. resolve the individual parts (i.e the exercise to a known exercise)

		if err := e.Resolve(); err != nil {
			// This means we'll need to do post processing - potentially first requiring manual
			// updates
			e.Type = "unknown"
		} else {
			searchResults, err := models.SearchExerciseDictionary(db, e.Name)
			if err != nil {
				return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
			}

			if len(searchResults) > 0 {
				minSearchRank := float32(0.05)
				topSearchResult := searchResults[0]

				fmt.Println("search compare", minSearchRank, topSearchResult)
				if topSearchResult.Rank >= minSearchRank {
					// if we didn't make it ot this if condition - but we resolved properly above
					// then that means we couldn't find a close enough match for the exercise
					e.ExerciseDictionaryID = &topSearchResult.ExerciseDictionaryID
				}
			}
		}

		workout.Exercises[i] = e
	}

	if err := db.Create(workout).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, workout)
}

func handlePutWorkout(c echo.Context) error {
	ctx := c.(*Context)

	tx := ctx.DB().Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	userID := getUserIDFromContext(ctx)

	workout := &models.Workout{}

	if err := ctx.Bind(workout); err != nil {
		tx.Rollback()
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	workout.UserID = userID // to make sure user isn't overriding this value

	for i, e := range workout.Exercises {
		if err := e.Resolve(); err != nil {
			tx.Rollback()
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}

		workout.Exercises[i] = e
	}

	existingWorkout := &models.Workout{}
	err := tx.
		Preload("Exercises").
		Preload("Exercises.WeightedExercise").
		Preload("Exercises.DistanceExercise").
		Where("id = ?", workout.ID).
		Where("user_id = ?", userID).
		First(existingWorkout).
		Error

	if err != nil {
		tx.Rollback()
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	for _, e := range existingWorkout.Exercises {
		if !workout.HasExercise(e.ID) {
			tx.Delete(&e)
		}
	}

	tx.Model(workout).Update(workout)

	if err := tx.Commit().Error; err != nil {
		tx.Rollback()
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, workout)
}

func handleDeleteWorkout(c echo.Context) error {
	ctx := c.(*Context)
	tx := ctx.DB().Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		tx.Rollback()
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	userID := getUserIDFromContext(ctx)

	workout := &models.Workout{}
	tx.
		Preload("Exercises").
		Preload("Exercises.WeightedExercise").
		Preload("Exercises.DistanceExercise").
		Where("id = ?", id).
		Where("user_id = ?", userID).
		First(workout).
		Delete(workout)

	for _, e := range workout.Exercises {
		tx.Where("id = ?", e.ID).Delete(&e)
	}

	if err := tx.Commit().Error; err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, workout)
}
