package server

import (
	"exercise_parser/models"
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/labstack/echo"
	"github.com/lestrrat-go/jwx/jwa"
	"github.com/lestrrat-go/jwx/jwk"
	"github.com/lestrrat-go/jwx/jws"
	"github.com/lestrrat-go/jwx/jwt"
	"github.com/spf13/viper"
)

// right now this only does "sign in with apple"
func handleUserRegistration(c echo.Context) error {
	ctx := c.(*Context)

	bearerToken := strings.Split(c.Request().Header.Get("Authorization"), " ")

	if viper.GetBool("middleware.auth") {
		// this is the check we do - before handing out a token

		// TODO: we should cache jwk
		jwkURL := "https://appleid.apple.com/auth/keys"
		set, err := jwk.Fetch(jwkURL)
		if err != nil {
			log.Printf("failed to parse JWK: %s", err)
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}

		_, err = jws.VerifyWithJWKSet([]byte(bearerToken[1]), set, nil)
		if err != nil {
			return ctx.JSON(http.StatusUnauthorized, newErrorMessage(err.Error()))
		}
	}

	user := &models.User{}
	if err := ctx.Bind(user); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	tx := ctx.DB().Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	err := tx.
		Where("external_user_id = ?", user.ExternalUserId).
		First(user).
		Error

	if err != nil {
		// then user doesn't exist so we create a new one
		if err := tx.Create(user).Error; err != nil {
			tx.Rollback()
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}
	}

	if err := tx.Commit().Error; err != nil {
		tx.Rollback()
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	// alrighty - lets create a token for this user. the jwt given
	// by apple only lasts for 10 minutes. SO - use apple token to
	// do a "login", and then handout our own jwt

	now := time.Unix(time.Now().Unix(), 0)

	t := jwt.New()

	// standard claims
	t.Set(jwt.AudienceKey, "ryden")
	t.Set(jwt.ExpirationKey, now.Add(7*24*time.Hour).Unix()) // a goddamn week
	t.Set(jwt.IssuedAtKey, now.Unix())
	t.Set(jwt.IssuerKey, "https://ryden.app")
	t.Set(jwt.SubjectKey, fmt.Sprint(user.ID))

	payload, err := t.Sign(jwa.RS256, ctx.key)

	type Response struct {
		Token string      `json:"token"`
		User  models.User `json:"user"`
	}

	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, Response{
		Token: string(payload),
		User:  *user,
	})
}

func handlePostRelatedName(c echo.Context) error {
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

func handleGetAllExerciseDictionary(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	results := []models.ExerciseDictionary{}

	err := db.
		Preload("Classification").
		Preload("Muscles").
		Preload("Articulation").
		Preload("Articulation.Joints").
		Order("name desc").
		Find(&results).
		Error

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	r := models.ListResponse{
		Count:   len(results),
		Results: results,
	}

	return ctx.JSON(http.StatusOK, r)
}
