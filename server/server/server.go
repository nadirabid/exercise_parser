package server

import (
	"crypto/rsa"
	"exercise_parser/models"
	"exercise_parser/parser"
	"fmt"
	"net/http/httputil"

	"github.com/jinzhu/gorm"
	"github.com/lestrrat-go/jwx/jwt"
	"golang.org/x/crypto/acme/autocert"

	_ "github.com/jinzhu/gorm/dialects/postgres" // dialect automatically used by gorm

	"github.com/spf13/viper"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

// Context is an extention of echo.Context
type Context struct {
	echo.Context
	db                *gorm.DB
	key               *rsa.PrivateKey
	viper             *viper.Viper
	jwt               *jwt.Token
	appleClientSecret string
}

// DB returns the database object used in handlers
func (c *Context) DB() *gorm.DB {
	return c.db
}

func newContext(v *viper.Viper, c echo.Context, db *gorm.DB) *Context {
	key, err := parseRsaPrivateKeyForTokenGeneration(v)
	if err != nil {
		panic(fmt.Sprintf("Failed to generate key: %s", err.Error()))
	}

	clientSecret, err := generateAppleClientSecret(v)
	if err != nil {
		panic(fmt.Sprintf("Failed to generate client secret: %s", err.Error()))
	}

	return &Context{
		c,
		db,
		key,
		v,
		nil,
		clientSecret,
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

	e.AutoTLSManager.Cache = autocert.DirCache("resources/.cache")

	e.Pre(middleware.RemoveTrailingSlash())

	e.Use(middleware.BodyDump(LogRequestResponse))

	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{}))

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

	apiRoutes := e.Group("/api")

	apiRoutes.Use(JWTAuthMiddleware)

	apiRoutes.GET("/exercise/unresolved", handleGetUnresolvedExercises)
	apiRoutes.POST("/exercise/unresolved/resolve", handleResolveAllUnresolvedExercises)
	apiRoutes.GET("/exercise/:id", handleGetExercise)
	apiRoutes.POST("/exercise/resolve", handleResolveExercise)
	apiRoutes.POST("/exercise", handlePostExercise)
	apiRoutes.PUT("/exercise/:id", handlePutExercise)
	apiRoutes.DELETE("/exercise/:id", handleDeleteExercise)

	apiRoutes.GET("/exercise/dictionary", handleGetAllExerciseDictionary)
	apiRoutes.POST("/exercise/dictionary/related", handlePostExerciseRelatedName)
	apiRoutes.GET("/exercise/dictionary/:id/related", handleGetExerciseRelatedName)

	apiRoutes.GET("/workout", handleGetAllWorkout)
	apiRoutes.GET("/workout/:id", handleGetWorkout)
	apiRoutes.POST("/workout", handlePostWorkout)
	apiRoutes.PUT("/workout", handlePutWorkout)
	apiRoutes.DELETE("/workout/:id", handleDeleteWorkout)

	return e.Start(fmt.Sprintf("0.0.0.0:%s", v.GetString("server.port")))
	//return e.StartTLS(":443", "resources/.cache/cert.pem", "resources/.cache/key.pem")
}
