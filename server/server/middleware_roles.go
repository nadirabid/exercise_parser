package server

import (
	"exercise_parser/utils"
	"net/http"

	"github.com/labstack/echo"
)

func MiddlewareRoles(next echo.HandlerFunc, hasRoles ...string) echo.HandlerFunc {
	return func(c echo.Context) error {
		ctx := c.(*Context)
		jwt := ctx.jwt

		if value, ok := jwt.Get(JWTKeySubjectRoles); ok {
			roles := value.([]interface{})

			for _, r := range roles {
				if utils.SliceContainsString(hasRoles, r.(string)) {
					return next(c)
				}
			}
		}

		return c.JSON(http.StatusUnauthorized, newErrorMessage("user does not have required authorization"))
	}
}
