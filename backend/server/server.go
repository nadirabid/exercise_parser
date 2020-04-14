package server

import (
	"crypto/rsa"
	"exercise_parser/models"
	"exercise_parser/parser"
	"fmt"
	"io/ioutil"
	"net/http/httputil"

	"github.com/jinzhu/gorm"
	"github.com/lestrrat-go/jwx/jwt"

	_ "github.com/jinzhu/gorm/dialects/postgres" // dialect automatically used by gorm

	"github.com/spf13/viper"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

// Context is an extention of echo.Context
type Context struct {
	echo.Context
	db    *gorm.DB
	key   *rsa.PrivateKey
	viper *viper.Viper
	jwt   *jwt.Token
}

// DB returns the database object used in handlers
func (c *Context) DB() *gorm.DB {
	return c.db
}

func newContext(v *viper.Viper, c echo.Context, db *gorm.DB) *Context {
	file := v.GetString("auth.file")
	bytes, err := ioutil.ReadFile(file)
	if err != nil {
		panic(fmt.Sprintf("Failed to open pem keypair file: %s", file))
	}

	key, err := parseRsaPrivateKeyFromPemStr(string(bytes))
	if err != nil {
		panic("Failed to generate key")
	}

	return &Context{
		c,
		db,
		key,
		v,
		nil,
	}
}

func LogRequestResponse(c echo.Context, reqBody, resBody []byte) {
	fmt.Println()
	fmt.Println("########")
	requestDump, err := httputil.DumpRequest(c.Request(), true)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(string(requestDump))
	fmt.Println(string(reqBody))
	fmt.Println(string(resBody))
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

	if err := models.Migrate(db); err != nil {
		return err
	}

	// init server

	e := echo.New()

	e.Pre(middleware.RemoveTrailingSlash())

	e.Use(middleware.BodyDump(LogRequestResponse))

	e.Use(middleware.LoggerWithConfig(middleware.LoggerConfig{
		Format: "method=${method}, uri=${uri}, status=${status}\n",
	}))

	e.Use(func(h echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			return h(newContext(v, c, db))
		}
	})

	e.POST("/user/register", handleUserRegistration)
	e.POST("/apple/callback", handleAppleAuthCallback)

	r := e.Group("")

	r.Use(JWTAuthMiddleware)

	r.GET("/exercise/unresolved", handleGetUnprocessedExercises)
	r.POST("/exercise/unresolved/resolve", handleResolveAllUnresolvedExercises)
	r.GET("/exercise/:id", handleGetExercise)
	r.POST("/exercise/resolve", handleResolveExercise)
	r.POST("/exercise", handlePostExercise)
	r.DELETE("/exercise/:id", handleDeleteExercise)

	r.GET("/exercise/dictionary", handleGetAllExerciseDictionary)
	r.POST("/exercise/dictionary/related", handlePostExerciseRelatedName)
	r.GET("/exercise/dictionary/:id/related", handleGetExerciseRelatedName)

	r.GET("/workout", handleGetAllWorkout)
	r.GET("/workout/:id", handleGetWorkout)
	r.POST("/workout", handlePostWorkout)
	r.PUT("/workout", handlePutWorkout)
	r.DELETE("/workout/:id", handleDeleteWorkout)

	return e.Start(fmt.Sprintf("0.0.0.0:%s", v.GetString("server.port")))
}
