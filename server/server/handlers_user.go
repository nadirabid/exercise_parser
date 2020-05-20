package server

import (
	"exercise_parser/models"
	"exercise_parser/utils"
	"net/http"
	"strconv"
	"strings"

	"github.com/labstack/echo"
)

func handlePostSubscribeMeToUser(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	subscribeToID, err := strconv.Atoi(ctx.Param("subscribe_to_id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	userID := getUserIDFromContext(ctx)

	s := &models.UserSubscription{
		SubscriberID:   userID,
		SubscribedToID: uint(subscribeToID),
	}

	if err := db.Where(*s).FirstOrCreate(s).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, nil)
}

// NOTE: this handler is temporary - hopefully??
func handleSubscribeAllUsersToAllUsers(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	allUsers := []models.User{}

	if err := db.Find(&allUsers).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	for _, subscriber := range allUsers {
		for _, subscribeTo := range allUsers {
			if subscriber.ID == subscribeTo.ID {
				continue
			}

			s := &models.UserSubscription{
				SubscriberID:   subscriber.ID,
				SubscribedToID: subscribeTo.ID,
			}

			if err := db.Where(*s).FirstOrCreate(s).Error; err != nil {
				return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
			}
		}
	}

	return ctx.JSON(http.StatusOK, nil)
}

func handleGetUsers(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	usersQuery := utils.GetStringOrDefault(ctx.QueryParam("users"), "")
	usersTokens := strings.Split(usersQuery, ",")

	if len(usersTokens) == 0 {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage("Query params users is empty"))
	}

	usersID := []uint{}
	for _, u := range usersTokens {
		id, err := strconv.Atoi(u)
		if err != nil {
			return ctx.JSON(http.StatusBadRequest, newErrorMessage("Query parameter must be valid comma sperated integers"))
		}

		usersID = append(usersID, uint(id))
	}

	// TODO:Security sanitize user data - really only name should get through
	// TODO:Security that the users the user is requesting access to is allowed

	users := []models.User{}
	q := db.Where(usersID)
	r, err := paging(q, 0, 0, &users)

	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, r)
}

func handlePatchMeUser(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	updatedUser := &models.User{}

	if err := ctx.Bind(updatedUser); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	updatedUser.ID = getUserIDFromContext(ctx) // to make sure someone isn't trying to update another

	// we do not want to change these value "empty" fields are ignored by gorm.Update
	updatedUser.ExternalUserId = ""
	updatedUser.Email = ""

	if err := db.Model(updatedUser).Update(*updatedUser).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, updatedUser)
}
