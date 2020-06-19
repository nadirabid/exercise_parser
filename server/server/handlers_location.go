package server

import (
	"exercise_parser/models"
	"exercise_parser/utils"
	"net/http"
	"strconv"

	"github.com/labstack/echo"
)

func handlePostLocationForExercise(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	location := &models.Location{}

	if err := ctx.Bind(location); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	if location.ExerciseID == nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage("location must have exercise_id"))
	}

	if err := db.Save(location).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, location)
}

func handlePostMultipleLocationsForExercise(c echo.Context) error {
	ctx := c.(*Context)

	queryParam, _ := strconv.Atoi(utils.GetStringOrDefault(ctx.QueryParam("page"), "-1"))

	if queryParam < 0 {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage("must specify valid exerciseID"))
	}

	exerciseID := uint(queryParam)

	locations := []*models.Location{}

	if err := ctx.Bind(&locations); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	tx := ctx.DB().Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	for _, l := range locations {
		l.ExerciseID = &exerciseID
		if err := tx.Create(&l).Error; err != nil {
			tx.Rollback()
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}
	}

	r := &models.ListResponse{
		Size:    len(locations),
		Page:    0,
		Results: locations,
	}

	return ctx.JSON(http.StatusOK, r)
}
