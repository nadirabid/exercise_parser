package server

import (
	"bytes"
	"encoding/json"
	"exercise_parser/models"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/labstack/echo"
	"github.com/lestrrat-go/jwx/jwk"
	"github.com/lestrrat-go/jwx/jwt"
)

type UserRegistrationData struct {
	UserId     string `json:"user_id"`
	Email      string `json:"email"`
	GivenName  string `json:"given_name"`
	FamilyName string `json:"family_name"`
}

func handleUserRegistration(c echo.Context) error {
	ctx := c.(*Context)

	// TODO: we should cache jwk
	jwkURL := "https://appleid.apple.com/auth/keys"
	set, err := jwk.Fetch(jwkURL)
	if err != nil {
		log.Printf("failed to parse JWK: %s", err)
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	bearerToken := strings.Split(c.Request().Header.Get("Authorization"), " ")

	fmt.Println("heree", bearerToken[1])
	token, err := jwt.Parse(bytes.NewReader([]byte(bearerToken[1])))
	if err != nil {
		// handle it
	}

	keyID, ok := token.Get("kid")
	if !ok {
		// handl it
	}

	keys := set.LookupKeyID(keyID.(string))

	fmt.Println("count", len(keys))

	res2B, _ := json.Marshal(set)
	fmt.Println(string(res2B))

	fmt.Println("key_id", set.Keys[0].KeyID())
	fmt.Println("key_id", set.Keys[1].KeyID())

	userRegistrationData := &UserRegistrationData{}
	if err := ctx.Bind(userRegistrationData); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	res3, _ := json.Marshal(userRegistrationData)
	fmt.Println("userRegiData", string(res3))

	return ctx.JSON(http.StatusOK, nil)
}

func handleGetAllWorkout(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	workouts := []models.Workout{}

	err := db.
		Preload("Exercises").
		Preload("Exercises.WeightedExercise").
		Preload("Exercises.DistanceExercise").
		Order("created_at desc").
		Find(&workouts).
		Error

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	r := models.ListResponse{
		Count:   len(workouts),
		Results: workouts,
	}

	return ctx.JSON(http.StatusOK, r)
}

func handleGetWorkout(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	workout := &models.Workout{}
	err = db.
		Preload("Exercises").
		Preload("Exercises.WeightedExercise").
		Preload("Exercises.DistanceExercise").
		Where("id = ?", id).
		First(workout).
		Error

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, workout)
}

func handlePostWorkout(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	workout := &models.Workout{}

	if err := ctx.Bind(workout); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	for i, e := range workout.Exercises {
		if err := e.Resolve(); err != nil {
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}

		searchResults, err := models.SearchExerciseDictionary(db, e.Name)
		if err != nil {
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}

		if len(searchResults) > 0 {
			minSearchRank := float32(0.05)
			topSearchResult := searchResults[0]

			fmt.Println("topSearchResult.rank", topSearchResult.Rank)
			if topSearchResult.Rank < minSearchRank {
				return ctx.JSON(http.StatusInternalServerError, fmt.Errorf("search results for %s have too low of rank", e.Name))
			}

			e.ExerciseDictionaryID = topSearchResult.ExerciseDictionaryID
		} else {
			return ctx.JSON(http.StatusInternalServerError, fmt.Errorf("couldn't resolve ExerciseDictionary entry for: %s", e.Name))
		}

		workout.Exercises[i] = e
	}

	if err := db.Create(workout).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, workout)
}

func handlePutWorkout(c echo.Context) error {
	ctx := c.(*Context)

	tx := ctx.DB().Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	workout := &models.Workout{}

	if err := ctx.Bind(workout); err != nil {
		tx.Rollback()
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	for i, e := range workout.Exercises {
		if err := e.Resolve(); err != nil {
			tx.Rollback()
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}

		workout.Exercises[i] = e
	}

	existingWorkout := &models.Workout{}
	err := tx.
		Preload("Exercises").
		Preload("Exercises.WeightedExercise").
		Preload("Exercises.DistanceExercise").
		Where("id = ?", workout.ID).
		First(existingWorkout).
		Error

	if err != nil {
		tx.Rollback()
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	for _, e := range existingWorkout.Exercises {
		if !workout.HasExercise(e.ID) {
			tx.Delete(&e)
		}
	}

	tx.Model(workout).Update(workout)

	if err := tx.Commit().Error; err != nil {
		tx.Rollback()
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, workout)
}

func handleDeleteWorkout(c echo.Context) error {
	ctx := c.(*Context)
	tx := ctx.DB().Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		tx.Rollback()
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	workout := &models.Workout{}
	tx.
		Preload("Exercises").
		Preload("Exercises.WeightedExercise").
		Preload("Exercises.DistanceExercise").
		Where("id = ?", id).
		First(workout).
		Delete(workout)

	for _, e := range workout.Exercises {
		tx.Where("id = ?", e.ID).Delete(&e)
	}

	if err := tx.Commit().Error; err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, workout)
}

func handleGetExercise(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	exercise := &models.Exercise{}
	err = db.
		Preload("WeightedExercise").
		Preload("DistanceExercise").
		Where("id = ?", id).
		First(exercise).
		Error

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, exercise)
}

func handleResolveExercise(c echo.Context) error {
	// this guy just resolves raw exercise text
	ctx := c.(*Context)

	exercise := &models.Exercise{}

	if err := ctx.Bind(exercise); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	if err := exercise.Resolve(); err != nil {
		return ctx.JSON(http.StatusInternalServerError, err.Error())
	}

	return ctx.JSON(http.StatusOK, exercise)
}

func handlePostExercise(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	exercise := &models.Exercise{}

	if err := ctx.Bind(exercise); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	if err := exercise.Resolve(); err != nil {
		return ctx.JSON(http.StatusInternalServerError, err.Error())
	}

	if err := db.Create(exercise).Error; err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, exercise)
}

func handleDeleteExercise(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.DB()

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	exercise := &models.Exercise{}

	err = db.
		Preload("WeightedExercise").
		Preload("DistanceExercise").
		Where("id = ?", id).
		First(exercise).
		Delete(exercise).
		Error

	if err != nil {
		return ctx.JSON(http.StatusNotFound, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, exercise)
}
