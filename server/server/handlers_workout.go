package server

import (
	"exercise_parser/metrics"
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
		Preload("Location").
		Preload("Exercises").
		Preload("Exercises.ExerciseData").
		Where("id = ?", id).
		Where("user_id = ?", userID).
		First(workout).
		Error

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, workout)
}

func handleGetAllUserWorkout(c echo.Context) error {
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
		Preload("Exercises.ExerciseData").
		Where("user_id = ?", userID).
		Order("created_at desc")

	listResponse, err := paging(q, page, size, &workouts)

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, listResponse)
}

func handleGetUserWorkoutSubscriptionFeed(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.db

	page, err := strconv.Atoi(utils.GetStringOrDefault(ctx.QueryParam("page"), "0"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	size, err := strconv.Atoi(utils.GetStringOrDefault(ctx.QueryParam("size"), "20"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	// userID := getUserIDFromContext(ctx)

	workouts := []models.Workout{}

	q := db.
		Preload("Location").
		Preload("Exercises").
		Preload("Exercises.ExerciseData").
		// Joins("JOIN user_subscriptions ON user_subscriptions.subscribed_to_id = workouts.user_id").
		// Where("user_subscriptions.subscriber_id = ? OR workouts.user_id = ?", userID, userID).
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
			ctx.logger.Errorf("Failed to resolve \"%s\" with error: %s", e.Raw, err.Error())
		} else {
			searchResults, err := models.SearchExerciseDictionary(ctx.viper, db, e.Name)
			if err != nil {
				return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
			}

			if len(searchResults) > 0 {
				minSearchRank := float32(0.05)
				topSearchResult := searchResults[0]

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

	go func() {
		ctx.logger.Infof("Compute metrics for workout: %s\n", workout.ID)

		if err := metrics.ComputeForWorkout(workout.ID, db); err != nil {
			ctx.logger.Error(err.Error())
		}

		ctx.logger.Infof("Complete metrics for workout: %s\n", workout.ID)
	}()

	return ctx.JSON(http.StatusOK, workout)
}

func handlePutWorkout(c echo.Context) error {
	ctx := c.(*Context)

	workoutID, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	userID := getUserIDFromContext(ctx)

	updatedWorkout := &models.Workout{}

	if err := ctx.Bind(updatedWorkout); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	for i, e := range updatedWorkout.Exercises {
		if err := e.Resolve(); err != nil {
			// This means we'll need to do post processing - potentially first requiring manual
			// updates
			e.Type = "unknown"
		} else {
			searchResults, err := models.SearchExerciseDictionary(ctx.viper, ctx.DB(), e.Name)
			if err != nil {
				return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
			}

			if len(searchResults) > 0 {
				minSearchRank := float32(0.05)
				topSearchResult := searchResults[0]

				if topSearchResult.Rank >= minSearchRank {
					// if we didn't make it ot this if condition - but we resolved properly above
					// then that means we couldn't find a close enough match for the exercise
					e.ExerciseDictionaryID = &topSearchResult.ExerciseDictionaryID
				}
			}
		}

		updatedWorkout.Exercises[i] = e
	}

	// start tx

	tx := ctx.DB().Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	existingWorkout := &models.Workout{}
	err = tx.
		Preload("Location").
		Preload("Exercises").
		Preload("Exercises.ExerciseData").
		Where("id = ?", uint(workoutID)).
		Where("user_id = ?", userID).
		First(existingWorkout).
		Error

	if err != nil {
		tx.Rollback()
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	fmt.Println("Existingworkout: ")
	utils.PrettyPrint(existingWorkout)

	for _, e := range existingWorkout.Exercises {
		if !updatedWorkout.HasExercise(e.ID) {
			fmt.Println("Deleted exercise: ", e.ID)
			tx.Delete(&e)
		}
	}

	// fields which we don't allow to be updated (at somepoint - we should have validators for this)
	updatedWorkout.ID = existingWorkout.ID
	updatedWorkout.Date = existingWorkout.Date
	updatedWorkout.SecondsElapsed = existingWorkout.SecondsElapsed
	updatedWorkout.UserID = existingWorkout.UserID
	updatedWorkout.Location = nil

	tx.Model(updatedWorkout).Update(*updatedWorkout)

	if err := tx.Commit().Error; err != nil {
		tx.Rollback()
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	updatedWorkout.Location = existingWorkout.Location // set back before returning

	go func() {
		ctx.logger.Infof("Compute metrics for workout: %s\n", existingWorkout.ID)

		if err := metrics.ComputeForWorkout(existingWorkout.ID, ctx.db); err != nil {
			ctx.logger.Error(err.Error())
		}

		ctx.logger.Infof("Complete metrics for workout: %s\n", existingWorkout.ID)
	}()

	return ctx.JSON(http.StatusOK, updatedWorkout)
}

func handleDeleteWorkout(c echo.Context) error {
	ctx := c.(*Context)

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	userID := getUserIDFromContext(ctx)

	w := &models.Workout{}
	w.ID = uint(id)

	q := ctx.DB().
		Unscoped().
		Where("user_id = ?", userID).
		Delete(w)

	if err := q.Error; err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, w)
}
