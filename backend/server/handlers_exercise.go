package server

import (
	"exercise_parser/models"
	"fmt"
	"net/http"
	"strconv"

	"github.com/labstack/echo"
)

func handleResolveExercise(c echo.Context) error {
	// this guy just resolves raw exercise text
	ctx := c.(*Context)

	exercise := &models.Exercise{}

	if err := ctx.Bind(exercise); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	if err := exercise.Resolve(); err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, exercise)
}

func handleGetExercise(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

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
	db := ctx.DB()

	exercise := &models.Exercise{}

	if err := ctx.Bind(exercise); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	if err := exercise.Resolve(); err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	if err := db.Create(exercise).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, exercise)
}

func handleDeleteExercise(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

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
		Delete(exercise).
		Error

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, exercise)
}

func handleGetAllExerciseDictionary(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	results := []models.ExerciseDictionary{}

	fmt.Println("#######", ctx.QueryParam("page"), ctx.QueryParam("size"))
	page, err := strconv.Atoi(getWithDefault(ctx.QueryParam("page"), "0"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	size, err := strconv.Atoi(getWithDefault(ctx.QueryParam("size"), "20"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	fmt.Println("HEREEEEEE", page, size)

	q := db.
		Preload("Classification").
		Preload("Muscles").
		Preload("Articulation").
		Preload("Articulation.Dynamic").
		Preload("Articulation.Static").
		Order("name asc")

	param := &Param{
		DB:    q,
		Limit: size,
		Page:  page,
	}

	r, err := getListResponse(param, &results)

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, r)
}

func handlePostExerciseRelatedName(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	relatedName := &models.ExerciseRelatedName{}

	if err := ctx.Bind(relatedName); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	if err := db.Create(relatedName).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, relatedName)
}

func handleGetExerciseRelatedName(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	related := []models.ExerciseRelatedName{}

	err = db.
		Where("exercise_dictionary_id = ?", id).
		Find(&related).
		Error

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	r := models.ListResponse{
		Results: related,
	}

	return ctx.JSON(http.StatusOK, r)
}
