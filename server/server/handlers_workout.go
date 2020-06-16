package server

import (
	"exercise_parser/metrics"
	"exercise_parser/models"
	"exercise_parser/utils"
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
		Preload("Exercises.Locations").
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
		Preload("Exercises.Locations").
		Where("user_id = ? AND in_progress = FALSE", userID).
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

	workouts := []models.Workout{}

	// TODO: filter out workouts which don't have any "processed/resolved" workouts - we're
	// currently doing this in the frontend but that means weird pagination bugs
	q := db.
		Preload("Location").
		Preload("Exercises").
		Preload("Exercises.ExerciseData").
		Preload("Exercises.Locations").
		Where("in_progress = FALSE").
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

		if err := e.Resolve(ctx.viper, db); err != nil {
			// This means we'll need to do post processing - potentially first requiring manual
			// updates
			ctx.logger.Errorf("Failed to resolve \"%s\" with error: %s", e.Raw, err.Error())
		}

		workout.Exercises[i] = e
	}

	if err := db.Set("gorm:association_autoupdate", false).Create(workout).Error; err != nil {
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
		Preload("Exercises.Locations").
		Where("id = ?", uint(workoutID)).
		Where("user_id = ?", userID).
		First(existingWorkout).
		Error

	if err != nil {
		tx.Rollback()
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	for _, e := range existingWorkout.Exercises {
		// clear out old related data
		tx.Model(&e).Association("ExerciseDictionaries").Clear()
		tx.Unscoped().Where("exercise_id = ?", e.ID).Delete(&models.ExerciseData{})
	}

	for i, e := range updatedWorkout.Exercises {
		if err := e.Resolve(ctx.viper, ctx.DB()); err != nil {
			ctx.logger.Errorf("Failed to resolve \"%s\" with error: %s", e.Raw, err.Error())
		} else {
			e.WorkoutID = updatedWorkout.ID  // for security
			e.ExerciseData.ExerciseID = e.ID // for security

			if err := tx.Set("gorm:association_autoupdate", false).Save(&e).Error; err != nil {
				ctx.logger.Error(utils.PrettyStringify(e))
				ctx.logger.Error(err.Error())
				return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
			}
		}

		updatedWorkout.Exercises[i] = e
	}

	// fields which we don't allow to be updated (at somepoint - we should have validators for this)
	updatedWorkout.ID = existingWorkout.ID
	updatedWorkout.Date = existingWorkout.Date
	updatedWorkout.SecondsElapsed = existingWorkout.SecondsElapsed
	updatedWorkout.UserID = existingWorkout.UserID
	updatedWorkout.Location = existingWorkout.Location

	tx.Set("gorm:association_autoupdate", false).Model(updatedWorkout).Update(*updatedWorkout)

	if err := tx.Commit().Error; err != nil {
		tx.Rollback()
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	go func() {
		ctx.logger.Infof("Compute metrics for workout: %s\n", existingWorkout.ID)

		if err := metrics.ComputeForWorkout(existingWorkout.ID, ctx.db); err != nil {
			ctx.logger.Error(err.Error())
		} else {
			ctx.logger.Infof("Complete metrics for workout: %s\n", existingWorkout.ID)
		}
	}()

	return ctx.JSON(http.StatusOK, updatedWorkout)
}

func handlePatchWorkoutAsComplete(c echo.Context) error {
	ctx := c.(*Context)

	workoutID, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	updatedWorkout := &models.Workout{}

	if err := ctx.Bind(updatedWorkout); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	userID := getUserIDFromContext(ctx)

	existingWorkout := &models.Workout{}
	err = ctx.DB().
		Preload("Location").
		Preload("Exercises").
		Preload("Exercises.ExerciseData").
		Preload("Exercises.Locations").
		Where("id = ?", uint(workoutID)).
		Where("user_id = ?", userID).
		First(existingWorkout).
		Error

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	// TODO: "resolve exercises here": in tehc ase of run tracker  type - we want to resolve exericse and generate metrics for run

	updatedWorkout.ID = existingWorkout.ID
	updatedWorkout.Date = existingWorkout.Date
	updatedWorkout.SecondsElapsed = existingWorkout.SecondsElapsed
	updatedWorkout.UserID = existingWorkout.UserID
	updatedWorkout.Location = existingWorkout.Location

	err = ctx.DB().Set("gorm:association_autoupdate", false).Model(updatedWorkout).Update(*updatedWorkout).Error

	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	go func() {
		ctx.logger.Infof("Compute metrics for workout: %s\n", existingWorkout.ID)

		if err := metrics.ComputeForWorkout(existingWorkout.ID, ctx.db); err != nil {
			ctx.logger.Error(err.Error())
		} else {
			ctx.logger.Infof("Complete metrics for workout: %s\n", existingWorkout.ID)
		}
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
		Set("gorm:association_autoupdate", false).
		Delete(w)

	if err := q.Error; err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, w)
}
