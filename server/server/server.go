package server

import (
	"compress/gzip"
	"crypto/rsa"
	"exercise_parser/models"
	"exercise_parser/parser"
	"fmt"
	"net/http/httputil"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"github.com/jinzhu/gorm"
	"github.com/lestrrat-go/jwx/jwt"
	"github.com/rifflock/lfshook"
	"github.com/sirupsen/logrus"

	"golang.org/x/crypto/acme/autocert"

	_ "github.com/jinzhu/gorm/dialects/postgres" // dialect automatically used by gorm

	"github.com/spf13/viper"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

// Context is an extention of echo.Context
type Context struct {
	echo.Context
	db         *gorm.DB
	key        *rsa.PrivateKey
	viper      *viper.Viper
	jwt        *jwt.Token
	logger     *logrus.Logger
	session    *session.Session
	uploader   *s3manager.Uploader
	downloader *s3manager.Downloader
}

// DB returns the database object used in handlers
func (c *Context) DB() *gorm.DB {
	return c.db
}

func newContext(
	v *viper.Viper,
	c echo.Context,
	db *gorm.DB,
	logger *logrus.Logger,
	sess *session.Session,
	uploader *s3manager.Uploader,
	downloader *s3manager.Downloader,
	tokenSigningKey *rsa.PrivateKey,

) *Context {
	return &Context{
		c,
		db,
		tokenSigningKey,
		v,
		nil,
		logger,
		sess,
		uploader,
		downloader,
	}
}

func newEchoRequestLogger(logger *logrus.Logger) func(echo.Context, []byte, []byte) {
	return func(c echo.Context, reqBody, resBody []byte) {
		requestDump, err := httputil.DumpRequest(c.Request(), true)
		if err != nil {
			logger.Error(err.Error())
		}

		logger.Info("Request Info:")
		logger.Info(string(requestDump))
		logger.Info(string(reqBody))
		logger.Info(string(resBody))
	}
}

// New returns Echo server
func New(v *viper.Viper) error {
	var err error

	// INIT LOGRUS

	logger := logrus.New()
	logger.SetReportCaller(true)

	loggingBaseDir := v.GetString("logging.base_dir")
	pathMap := lfshook.PathMap{
		logrus.ErrorLevel: fmt.Sprintf("%s/error.log", loggingBaseDir),
	}

	logger.Hooks.Add(lfshook.NewHook(
		pathMap,
		&logrus.JSONFormatter{},
	))

	// INIT S3

	s3Region := v.GetString("s3.region")
	var sess *session.Session
	var uploader *s3manager.Uploader
	var downloader *s3manager.Downloader

	if v.GetBool("s3.enabled") {
		sess = session.Must(session.NewSession(
			&aws.Config{
				Region: aws.String(s3Region),
			},
		))

		uploader = s3manager.NewUploader(sess)
		downloader = s3manager.NewDownloader(sess)
	}

	// INIT AUTH TOKEN KEYS

	tokenSigningKey, err := parseRsaPrivateKeyForTokenGeneration(v)
	if err != nil {
		panic(fmt.Sprintf("Failed to generate key: %s", err.Error()))
	}

	// INIT PARSER

	if err := parser.Init(v); err != nil {
		return err
	}

	// INIT DATABASE

	db, err := models.NewDatabase(v)
	if err != nil {
		return err
	}

	// INIT SERVER

	e := echo.New()

	e.AutoTLSManager.Cache = autocert.DirCache("resources/.cache")

	e.Pre(middleware.RemoveTrailingSlash())

	//e.Use(middleware.BodyDump(newEchoRequestLogger(logger)))

	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{}))

	e.Use(middleware.LoggerWithConfig(middleware.LoggerConfig{
		Format: "method=${method}, uri=${uri}, status=${status}\n",
	}))

	e.Use(middleware.GzipWithConfig(middleware.GzipConfig{
		Level: gzip.BestCompression,
	}))

	e.Use(func(h echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			return h(newContext(
				v,
				c,
				db,
				logger,
				sess,
				uploader,
				downloader,
				tokenSigningKey,
			))
		}
	})

	e.POST("/user/register", handleUserRegistration)
	e.POST("/apple/callback", handleAppleAuthCallback)

	apiRoutes := e.Group("/api")

	apiRoutes.Use(MiddlewareJWTAuth)

	// returns user
	apiRoutes.GET("/user", handleGetUsers)
	apiRoutes.PATCH("/user/me", handlePatchMeUser)
	apiRoutes.GET("/user/:id/image", handleGetMeUserImage)
	apiRoutes.POST("/user/me/image", handlePostMeUserImage)
	apiRoutes.POST("/user/me/subscribe/:subscribe_to_id", handlePostSubscribeMeToUser)
	apiRoutes.POST("/user/subscribe/alltoall", handleSubscribeAllUsersToAllUsers)

	// returns exercise
	apiRoutes.POST("/exercise/resolve", handleResolveExercise)
	apiRoutes.GET("/exercise/unresolved", MiddlewareRoles(handleGetUnresolvedExercises, "admin"))
	apiRoutes.POST("/exercise/unresolved/resolve", MiddlewareRoles(handlePostReresolveExercises))
	apiRoutes.GET("/exercise/unmatched", MiddlewareRoles(handleGetUnmatchedExercises))
	apiRoutes.POST("/exercise/unmatched/rematch", MiddlewareRoles(handlePostRematchExercises))
	apiRoutes.GET("/exercise/:id", handleGetExercise)
	apiRoutes.POST("/exercise", handlePostExercise)
	apiRoutes.PUT("/exercise/:id", handlePutExercise)
	apiRoutes.DELETE("/exercise/:id", handleDeleteExercise)

	// returns dictionary
	apiRoutes.GET("/dictionary", MiddlewareRoles(handleGetExerciseDictionaryList))
	apiRoutes.GET("/dictionary/search", MiddlewareRoles(handleGetSearchDictionary))
	apiRoutes.GET("/dictionary/:id", handleGetDictionary)
	apiRoutes.GET("/workout/:id/dictionary", handleGetWorkoutDictionary)

	// returns related names
	apiRoutes.POST("/exercise/dictionary/related", MiddlewareRoles(handlePostDictionaryRelatedName))
	apiRoutes.PUT("/exercise/dictionary/related/:id", MiddlewareRoles(handlePutDictionaryRelatedName))
	apiRoutes.GET("/exercise/dictionary/:id/related", MiddlewareRoles(handleGetDictionaryRelatedName))

	// returns workout
	apiRoutes.GET("/workout/subscribedto", handleGetUserWorkoutSubscriptionFeed)
	apiRoutes.GET("/workout", handleGetAllUserWorkout)
	apiRoutes.GET("/workout/:id", handleGetWorkout)
	apiRoutes.POST("/workout", handlePostWorkout)
	apiRoutes.PUT("/workout/:id", handlePutWorkout)
	apiRoutes.DELETE("/workout/:id", handleDeleteWorkout)

	// returns metrics
	apiRoutes.GET("/metric", handleGetMetrics)
	apiRoutes.GET("/metric/weekly", handleGetWeeklyMetrics) // TODO: remove this dude when everyone is using app 24 build

	return e.Start(fmt.Sprintf("0.0.0.0:%s", v.GetString("server.port")))
}
