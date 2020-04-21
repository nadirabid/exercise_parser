package server

import (
	"exercise_parser/models"
	"exercise_parser/utils"
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

	err := db.
		Where("type = ?", "unknown").
		Find(&exercises).
		Error

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	for _, e := range exercises {
		if err := e.Resolve(); err != nil {
			return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
		}

		// TODO: should we also rematch to an exercise??
	}

	return ctx.JSON(http.StatusOK, exercises)
}

// exercise dictionary handlers

func handleGetExerciseDictionaryList(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	results := []models.ExerciseDictionary{}

	page, err := strconv.Atoi(utils.GetStringOrDefault(ctx.QueryParam("page"), "0"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	size, err := strconv.Atoi(utils.GetStringOrDefault(ctx.QueryParam("size"), "20"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	q := db.
		Preload("Classification").
		Preload("Muscles").
		Preload("Articulation").
		Preload("Articulation.Dynamic").
		Preload("Articulation.Static").
		Order("name asc")

	listResponse, err := paging(q, page, size, &results)

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, listResponse)
}

func handleGetDictionaryRelatedName(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	related := []models.ExerciseRelatedName{}

	q := db.Where("exercise_dictionary_id = ?", id)

	r, err := paging(q, 0, 0, &related)

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, r)
}

func handlePostDictionaryRelatedName(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	relatedName := &models.ExerciseRelatedName{}

	if err := ctx.Bind(relatedName); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	relatedName.Type = ctx.viper.GetString("resources.dir.related_names")

	if err := db.Create(relatedName).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	if err := relatedName.UpdateTSV(db); err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, relatedName)
}

func handlePutDictionaryRelatedName(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	relatedName := &models.ExerciseRelatedName{}

	if err := ctx.Bind(relatedName); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	if err := db.Save(relatedName).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	if err := relatedName.UpdateTSV(db); err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, relatedName)
}
