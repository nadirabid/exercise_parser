package server

import (
	"exercise_parser/utils"
	"net/http"

	"github.com/labstack/echo"
	"github.com/lib/pq"
)

func MiddlewareRoles(next echo.HandlerFunc, hasRoles ...string) echo.HandlerFunc {
	return func(c echo.Context) error {
		ctx := c.(*Context)
		jwt := ctx.jwt

		if value, ok := jwt.Get(JWTKeySubjectRoles); ok {
			roles := []string(value.(pq.StringArray))

			for _, r := range roles {
				if utils.SliceContainsString(roles, r) {
					return next(c)
				}
			}
		}

		return c.JSON(http.StatusUnauthorized, newErrorMessage("user does not have required authorization"))
	}
}
