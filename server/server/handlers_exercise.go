package server

import (
	"exercise_parser/models"
	"fmt"
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
		Preload("ExerciseData").
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

	if err := exercise.Resolve(ctx.viper, ctx.DB()); err != nil {
		fmt.Println("err", err)
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
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

	if err := exercise.Resolve(ctx.viper, ctx.DB()); err != nil {
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

	// TODO: remove all this stuff
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
		Preload("ExerciseData").
		Where("id = ?", id).
		First(exercise).
		Delete(exercise).
		Error

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, exercise)
}

func handleGetUnresolvedExercises(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	exercises := []models.Exercise{}

	q := db.Preload("ExerciseData").Where("resolution_type = ?", "")

	r, err := paging(q, 0, 0, &exercises)

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, r)
}

func handleGetUnmatchedExercises(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	exercises := []models.Exercise{}

	q := db.
		Preload("ExerciseData").
		Where("exercise_dictionary_id IS NULL and resolution_type != ?", "")

	r, err := paging(q, 0, 0, &exercises)

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, r)
}

func handlePostRematchExercises(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	exercises := []models.Exercise{}

	err := db.
		Where("exercise_dictionary_id IS NULL and resolution_type != ?", "").
		Find(&exercises).
		Error

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	matchedExercises := []models.Exercise{}

	for _, e := range exercises {
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

		if err := db.Save(&e).Error; err != nil {
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}

		matchedExercises = append(matchedExercises, e)
	}

	r := models.ListResponse{
		Size:    len(matchedExercises),
		Page:    0,
		Results: matchedExercises,
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

	resolvedExercises := []models.Exercise{}

	for _, e := range exercises {
		if err := e.Resolve(ctx.viper, ctx.DB()); err == nil {
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

			if err := db.Save(&e).Error; err != nil {
				return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
			}

			resolvedExercises = append(resolvedExercises, e)
		} else {
			ctx.logger.Errorf("Failed to parse exercise %s with error: ", e.Raw, err)
		}
	}

	r := models.ListResponse{
		Size:    len(resolvedExercises),
		Page:    0,
		Results: resolvedExercises,
	}

	return ctx.JSON(http.StatusOK, r)
}
