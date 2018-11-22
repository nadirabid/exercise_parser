package server

import (
	"exercise_parser/models"
	"fmt"
	"net/http"
	"strconv"

	_ "github.com/jinzhu/gorm/dialects/postgres"

	"github.com/spf13/viper"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

// New returns Echo server
func New(v *viper.Viper) error {
	// init database

	db, err := models.NewDatabase(v)
	if err != nil {
		return err
	}

	models.Migrate(db)

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

		exercise := &models.Exercise{}
		db.First(exercise, id)

		return c.JSON(http.StatusOK, exercise)
	})

	e.POST("/exercise", func(c echo.Context) error {
		exercise := &models.Exercise{}

		if err := c.Bind(exercise); err != nil {
			e.Logger.Error(err)
		}

		res, err := Resolve(exercise.Raw)
		if err != nil {
			return c.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}

		exercise.Type = res.Type
		exercise.Name = res.Captures["Exercise"]

		if res.Type == "weighted" {
			sets, err := strconv.Atoi(res.Captures["Sets"])
			if err != nil {
				return c.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
			}

			reps, err := strconv.Atoi(res.Captures["Reps"])
			if err != nil {
				return c.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
			}

			weightedExercise := &models.WeightedExercise{
				Sets: sets,
				Reps: reps,
			}

			exercise.WeightedExercise = weightedExercise

			db.Create(exercise)
			db.Create(exercise.WeightedExercise)
		} else if res.Type == "distance" {
			time := res.Captures["Time"]
			units := res.Captures["Units"]

			distance, err := strconv.ParseFloat(res.Captures["Distance"], 32)
			if err != nil {
				return c.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
			}

			distanceExercise := &models.DistanceExercise{
				Time:     time,
				Distance: float32(distance),
				Units:    units,
			}

			exercise.DistanceExercise = distanceExercise

			db.Create(exercise)
			db.Create(exercise.DistanceExercise)
		}

		return c.JSON(http.StatusOK, exercise)
	})

	e.Logger.Fatal(e.Start(fmt.Sprintf("0.0.0.0:%s", v.GetString("server.port"))))
	return nil
}
