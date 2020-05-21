package server

import (
	"exercise_parser/models"
	"exercise_parser/utils"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"github.com/labstack/echo"
	uuid "github.com/satori/go.uuid"
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

func handleGetMeUserImage(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	user := &models.User{}
	user.ID = uint(id)

	if err := db.Where(user).First(user).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	if ctx.viper.GetString("images.storage_type") == "file" {
		dir := ctx.viper.GetString("images.file.user_image_dir")
		fullImagePath := fmt.Sprintf("%s/%s", dir, user.ImagePath)

		return c.File(fullImagePath)
	}

	svc := s3.New(ctx.session)

	bucket := ctx.viper.GetString("images.s3.bucket")
	fullKeyName := fmt.Sprintf("%s/%s", ctx.viper.GetString("images.s3.user_image_key_name"), user.ImagePath)

	req, _ := svc.GetObjectRequest(&s3.GetObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(fullKeyName),
	})

	url, err := req.Presign(time.Minute * 1)

	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.Redirect(http.StatusFound, url)
}

func handlePostMeUserImage(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	fileHeader, err := ctx.FormFile("file")
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	file, err := fileHeader.Open()
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}
	defer file.Close()

	user := &models.User{}
	user.ID = getUserIDFromContext(ctx)
	user.ImagePath = fmt.Sprintf("%s.jpg", uuid.NewV4().String())

	if ctx.viper.GetString("images.storage_type") == "file" {
		userImageDir := ctx.viper.GetString("images.file.user_image_dir")
		imageFilePath := fmt.Sprintf("%s/%s", userImageDir, user.ImagePath)

		if _, err := os.Stat(userImageDir); os.IsNotExist(err) {
			if err := os.MkdirAll(userImageDir, os.ModePerm); err != nil {
				return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
			}
		}

		bytes, err := ioutil.ReadAll(file)
		if err != nil {
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}

		if err := ioutil.WriteFile(imageFilePath, bytes, 0644); err != nil {
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}
	} else if ctx.viper.GetString("images.storage_type") == "s3" {
		bucket := ctx.viper.GetString("images.s3.bucket")
		keyName := ctx.viper.GetString("images.s3.user_image_key_name")

		_, err = ctx.uploader.Upload(&s3manager.UploadInput{
			Bucket: aws.String(bucket),
			Key:    aws.String(fmt.Sprintf("%s/%s", keyName, user.ImagePath)),
			Body:   file,
		})

		if err != nil {
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}
	}

	if err := db.Model(user).Update(*user).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, err.Error())
	}

	return ctx.JSON(http.StatusOK, nil)
}
