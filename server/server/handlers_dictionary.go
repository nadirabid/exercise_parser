package server

import (
	"exercise_parser/models"
	"exercise_parser/utils"
	"fmt"
	"net/http"
	"net/url"
	"regexp"
	"strconv"
	"strings"

	"github.com/labstack/echo"
)

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

	q := db.Preload("Muscles").Order("name asc")

	listResponse, err := paging(q, page, size, &results)

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, listResponse)
}

func handleGetDictionary(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	d := &models.ExerciseDictionary{}

	err = db.
		Preload("Muscles").
		Where("id = ?", id).
		First(d).
		Error

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, d)
}

func handleGetSearchDictionary(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.db

	exerciseQuery := ctx.QueryParam("query")

	if exerciseQuery == "" {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage("You have to specify url query parameter: 'query'"))
	}

	searchResults, err := models.SearchExerciseDictionary(ctx.viper, db, exerciseQuery)
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

var alphanumericExp = regexp.MustCompile(`[^a-zA-Z0-9\s]+`)

func handleGetSearchDictionaryLite(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.db

	exerciseQuery, err := url.QueryUnescape(ctx.QueryParam("query"))
	exerciseQuery = alphanumericExp.ReplaceAllString(exerciseQuery, "")
	exerciseQuery = strings.TrimSpace(exerciseQuery)
	fmt.Println(exerciseQuery)

	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	if exerciseQuery == "" {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage("You have to specify url query parameter: 'query'"))
	}

	searchResults, err := models.SearchExerciseDictionaryLite(ctx.viper, db, exerciseQuery)
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

func handleGetWorkoutDictionary(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	workoutID, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	dictionaries := []models.ExerciseDictionary{}

	q := db.
		Preload("Muscles").
		Select("DISTINCT ON (exercise_dictionaries.id) exercise_dictionaries.*").
		Joins("JOIN resolved_exercise_dictionaries ON resolved_exercise_dictionaries.exercise_dictionary_id = exercise_dictionaries.id").
		Joins("JOIN exercises ON exercises.id = resolved_exercise_dictionaries.exercise_id").
		Joins("JOIN workouts ON workouts.id = exercises.workout_id").
		Where("workouts.id = ?", workoutID)

	r, err := paging(q, 0, 0, &dictionaries)

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, r)
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
