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
