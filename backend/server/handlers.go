package server

import (
	"exercise_parser/models"
	"fmt"
	"io/ioutil"
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

func handleAppleAuthCallback(c echo.Context) error {
	// https://developer.okta.com/blog/2019/06/04/what-the-heck-is-sign-in-with-apple
	// https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens
	ctx := c.(*Context)

	fmt.Println(ctx.Request().Form)

	bytes, err := ioutil.ReadFile("resources/dev_keys/apple.key.p8")
	if err != nil {
		return err
	}

	key, err := parseECDSAPrivateKeyFromStr(bytes)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	now := time.Unix(time.Now().Unix(), 0)

	t := jwt.New()

	t.Set(jwt.AudienceKey, "https://appleid.apple.com")
	t.Set(jwt.IssuedAtKey, now.Unix())
	t.Set(jwt.ExpirationKey, now.Add(7*24*time.Hour).Unix()) // a goddamn week
	t.Set(jwt.IssuerKey, "C3HW5VXXF5")
	t.Set(jwt.SubjectKey, "ryden.web")

	payload, err := signJWT(t, jwa.ES256, key, "PHK94N7Y9A")
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}
	fmt.Println(string(payload))

	return ctx.JSON(http.StatusOK, nil)
}
