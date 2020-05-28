package server

import (
	"bytes"
	"exercise_parser/models"
	"net/http"
	"strings"

	"github.com/labstack/echo"
	"github.com/lestrrat-go/jwx/jwa"
	"github.com/lestrrat-go/jwx/jwt"
)

func MiddlewareJWTAuth(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		ctx := c.(*Context)

		authorization := c.Request().Header.Get("Authorization")

		if authorization == "" && !ctx.viper.GetBool("middleware.auth") {
			// when auth is disabled - and there is no token - we'll create one
			fakeUser := models.User{}
			if err := ctx.db.Where("external_user_id = 'fake.user.id'").First(&fakeUser).Error; err != nil {
				return c.JSON(http.StatusNotFound, newErrorMessage("Seed fake user! Cannot authenticate."))
			}

			ctx.jwt = generateFakeUserJWT(fakeUser)

			return next(ctx)
		} else if authorization == "" {
			return c.JSON(
				http.StatusUnauthorized,
				newErrorMessage("Authorization header is unspecified"),
			)
		}

		token := strings.Split(authorization, " ")

		if len(token) != 2 {
			return c.JSON(
				http.StatusUnauthorized,
				newErrorMessage("Authorization should have format: Bearer <token>"),
			)
		}

		jwt, err := jwt.Parse(
			bytes.NewReader([]byte(token[1])),
			jwt.WithVerify(jwa.RS256, &(ctx.key.PublicKey)),
		)

		if err != nil {
			return c.JSON(
				http.StatusUnauthorized,
				newErrorMessage(err.Error()),
			)
		}

		ctx.jwt = jwt

		return next(ctx)
	}
}
