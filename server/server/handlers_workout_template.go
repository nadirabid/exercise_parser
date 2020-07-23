package server

import (
	"exercise_parser/models"
	"exercise_parser/utils"
	"net/http"
	"strconv"

	"github.com/labstack/echo"
)

func handleGetWorkoutTemplate(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	userID := getUserIDFromContext(ctx)

	workoutTemplate := &models.WorkoutTemplate{}
	err = db.
		Preload("ExerciseTemplates").
		Preload("ExerciseTemplates.Data").
		Preload("ExerciseTemplates.ExerciseDictionaries").
		Where("id = ?", id).
		Where("user_id = ?", userID).
		First(workoutTemplate).
		Error

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, workoutTemplate)
}

func handleGetAllUserWorkoutTemplates(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	page, err := strconv.Atoi(utils.GetStringOrDefault(ctx.QueryParam("page"), "0"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	size, err := strconv.Atoi(utils.GetStringOrDefault(ctx.QueryParam("size"), "20"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	userID := getUserIDFromContext(ctx)

	workoutTemplates := []models.WorkoutTemplate{}
	q := db.
		Preload("ExerciseTemplates").
		Preload("ExerciseTemplates.Data").
		Preload("ExerciseTemplates.ExerciseDictionaries").
		Where("user_id = ?", userID).
		Order("created_at desc")

	listResponse, err := paging(q, page, size, &workoutTemplates)

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, listResponse)
}

func handlePostWorkoutTemplate(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	userID := getUserIDFromContext(ctx)

	workoutTemplate := &models.WorkoutTemplate{}

	if err := ctx.Bind(workoutTemplate); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	workoutTemplate.UserID = userID

	if err := db.Set("gorm:association_autoupdate", false).Create(workoutTemplate).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, workoutTemplate)
}

func handlePutWorkoutTemplate(c echo.Context) error {
	ctx := c.(*Context)

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	updated := &models.WorkoutTemplate{}
	if err := ctx.Bind(updated); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	userID := getUserIDFromContext(ctx)

	// start tx

	tx := ctx.DB().Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	existing := models.WorkoutTemplate{}
	err = tx.
		Preload("ExerciseTemplates").
		Preload("ExerciseTemplates.Data").
		Preload("ExerciseTemplates.ExerciseDictionaries").
		Where("id = ?", id).
		Where("user_id = ?", userID).
		First(existing).
		Error

	if err != nil {
		tx.Rollback()
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	for _, t := range existing.ExerciseTemplates {
		tx.Model(&t).Association("ExerciseDictionaries").Clear()
		tx.Unscoped().Where("exercise_template_id").Delete(&models.ExerciseTemplateData{})
	}

	for i, t := range updated.ExerciseTemplates {
		t.WorkoutTemplateID = uint(id)   // for security
		t.Data.ExerciseTemplateID = t.ID // for security

		if err := tx.Set("gorm:association_autoupdate", false).Save(&t).Error; err != nil {
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}

		updated.ExerciseTemplates[i] = t
	}

	updated.ID = existing.ID
	updated.UserID = existing.UserID

	tx.Set("gorm:association_autoupdate", false).Model(existing).Update(*updated)

	if err := tx.Commit().Error; err != nil {
		tx.Rollback()
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, updated)
}

func handleDeleteWorkoutTemplate(c echo.Context) error {
	ctx := c.(*Context)

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	userID := getUserIDFromContext(ctx)

	workoutTemplate := &models.WorkoutTemplate{}
	workoutTemplate.ID = uint(id)

	q := ctx.DB().
		Unscoped().
		Where("user_id = ?", userID).
		Set("gorm:association_autoupdate", false). // so we don't delete what exactly??
		Delete(workoutTemplate)

	if err := q.Error; err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, workoutTemplate)
}
