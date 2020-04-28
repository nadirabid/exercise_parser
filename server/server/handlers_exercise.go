package server

import (
	"exercise_parser/models"
	"net/http"
	"strconv"

	"github.com/labstack/echo"
)

// exercise handlers

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

	// TODO: should we also do a match to dictionary???

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

func handlePutExercise(c echo.Context) error {
	// technically this url gets called with id (.ie /exercise/:id/)
	ctx := c.(*Context)
	db := ctx.DB()

	exercise := &models.Exercise{}

	if err := ctx.Bind(exercise); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	if exercise.Type == "weighted" && exercise.WeightedExercise != nil {
		return ctx.JSON(http.StatusNotAcceptable, newErrorMessage("type is weighted but weighted fields are not supplied"))
	}

	if exercise.Type == "distance" && exercise.DistanceExercise != nil {
		return ctx.JSON(http.StatusNotAcceptable, newErrorMessage("type is distance but distance fields are not supplied"))
	}

	exercise.ResolutionType = "manual"

	// we don't resolve exercise - this endpoint is meant to be for a "manual resolve"

	if err := db.Save(exercise).Error; err != nil {
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

func handleSearchExercise(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.db

	exerciseQuery := ctx.QueryParam("exerciseQuery")

	if exerciseQuery == "" {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage("You have to specify 'exerciseQuery' query parameter'"))
	}

	searchResults, err := models.SearchExerciseDictionary(db, exerciseQuery)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	r := models.ListResponse{
		Page:    1,
		Pages:   1,
		Size:    0,
		Results: searchResults,
	}

	return ctx.JSON(http.StatusOK, r)
}

func handleGetUnresolvedExercises(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	exercises := []models.Exercise{}

	q := db.Where("type = ?", "unknown")

	r, err := paging(q, 0, 0, &exercises)

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, r)
}

func handleGetUnmatchedExercises(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	exercise := []models.Exercise{}

	q := db.Where("exercise_dictionary_id IS NULL and type != ?", "unknown")

	r, err := paging(q, 0, 0, &exercise)

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, r)
}

func handlePostReresolveExercises(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	exercises := []models.Exercise{}

	err := db.Debug().
		Where("type = ?", "unknown").
		Find(&exercises).
		Error

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	resolvedExercises := []models.Exercise{}

	for _, e := range exercises {
		if err := e.Resolve(); err == nil {
			resolvedExercises = append(resolvedExercises, e)
			if err := db.Save(&e).Error; err != nil {
				return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
			}
		}

		// TODO: log the ones we failed to resolve?
		// TODO: should we also rematch to an exercise??
	}

	return ctx.JSON(http.StatusOK, resolvedExercises)
}
