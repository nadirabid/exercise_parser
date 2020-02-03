package server

import (
	"exercise_parser/models"
	"exercise_parser/parser"
	"fmt"

	"github.com/jinzhu/gorm"

	_ "github.com/jinzhu/gorm/dialects/postgres" // dialect automatically used by gorm

	"github.com/spf13/viper"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

// Context is an extention of echo.Context
type Context struct {
	echo.Context
	db *gorm.DB
}

// DB returns the database object used in handlers
func (c *Context) DB() *gorm.DB {
	return c.db
}

func newContext(c echo.Context, db *gorm.DB) *Context {
	return &Context{
		c,
		db,
	}
}

// New returns Echo server
func New(v *viper.Viper) error {
	// init parser

	if err := parser.Init(v); err != nil {
		return err
	}

	// init database

	db, err := models.NewDatabase(v)
	if err != nil {
		return err
	}

	models.Migrate(db)

	// init server

	e := echo.New()

	e.Pre(middleware.RemoveTrailingSlash())

	e.Use(middleware.LoggerWithConfig(middleware.LoggerConfig{
		Format: "method=${method}, uri=${uri}, status=${status}\n",
	}))

	e.Use(func(h echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			return h(newContext(c, db))
		}
	})

	e.GET("/exercise/:id", handleGetExercise)
	e.POST("/exercise", handlePostExercise)
	e.DELETE("/exercise/:id", handleDeleteExercise)

	e.GET("/workout", handleGetAllWorkout)
	e.GET("/workout/:id", handleGetWorkout)
	e.POST("/workout", handlePostWorkout)
	e.PUT("/workout", handlePutWorkout)
	e.DELETE("/workout/:id", handleDeleteWorkout)

	e.Logger.Fatal(e.Start(fmt.Sprintf("0.0.0.0:%s", v.GetString("server.port"))))
	return nil
}
