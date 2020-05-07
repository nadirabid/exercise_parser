package server

import (
	"exercise_parser/models"
	"net/http"
	"strconv"

	"github.com/labstack/echo"
)

func handlePostSubscribeToUser(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	subscribeToID, err := strconv.Atoi(ctx.Param("subscribe_to_id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	userID := getUserIDFromContext(ctx)

	subscription := &models.UserSubscription{
		SubscriberID:   userID,
		SubscribedToID: uint(subscribeToID),
	}

	if err := db.FirstOrCreate(subscription).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, nil)
}
