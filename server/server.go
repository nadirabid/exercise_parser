package server

import (
	"exercise_parser/models"
	"fmt"
	"net/http"
	"strconv"

	"gopkg.in/src-d/go-kallax.v1"

	"github.com/spf13/viper"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

// New returns Echo server
func New(v *viper.Viper) error {
	// init databaste

	db, err := models.NewDatabase(v)
	if err != nil {
		return err
	}

	// init server

	e := echo.New()
	e.Pre(middleware.RemoveTrailingSlash())

	e.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "Hello, World!")
	})

	e.GET("/exercise/:id", func(c echo.Context) error {
		id, err := strconv.Atoi(c.Param("id"))

		if err != nil {
			return c.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
		}

		s := models.NewExerciseStore(db)
		q := models.NewExerciseQuery().Where(kallax.Eq(models.Schema.Exercise.ID, id))

		exercise, err := s.FindOne(q)
		if err != nil {
			return c.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
		}

		return c.JSON(http.StatusOK, exercise)
	})

	e.POST("/exercise", func(c echo.Context) error {
		exercise := &models.Exercise{}

		if err := c.Bind(exercise); err != nil {
			e.Logger.Error(err)
		}

		s := models.NewExerciseStore(db)
		if _, err := s.Save(exercise); err != nil {
			e.Logger.Error(err)
		}

		return c.JSON(http.StatusOK, exercise)
	})

	e.Logger.Fatal(e.Start(fmt.Sprintf("0.0.0.0:%s", v.GetString("server.port"))))
	return nil
}
