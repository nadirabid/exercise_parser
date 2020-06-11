package server

import (
	"exercise_parser/models"
	"net/http"

	"github.com/labstack/echo"
)

func handlePostLocation(c echo.Context) error {
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
