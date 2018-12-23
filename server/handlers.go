package server

import (
	"exercise_parser/models"
	"fmt"
	"net/http"
	"sort"
	"strconv"
	"strings"

	"github.com/jinzhu/gorm"
	"github.com/labstack/echo"
)

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

// ResolveResult holds the result values w/ rank info
type ResolveResult struct {
	models.ExerciseRelatedName
	Rank float32
}

type AggregateRelated struct {
	Name string  `json:"name"`
	Rank float32 `json:"rank"`
}

type AggregatedResult struct {
	Primary string             `json:"primary"`
	Rank    float32            `json:"rank"`
	Related []AggregateRelated `json:"related"`
}

// ResolveHelper will print the search results
func ResolveHelper(db *gorm.DB, name string) ([]*AggregatedResult, error) {
	searchTerms := strings.Join(strings.Split(name, " "), " & ")

	q := `
		SELECT *, ts_rank(related_tsv, keywords, 2) AS rank
		FROM exercise_related_names, to_tsquery(?) keywords
		WHERE related_tsv @@ keywords
		ORDER BY rank DESC
	`

	rows, err := db.Raw(q, searchTerms).Rows()
	if err != nil {
		return nil, err
	}

	defer rows.Close()

	groupedByPrimary := make(map[string][]*ResolveResult)
	for rows.Next() {
		res := &ResolveResult{}
		db.ScanRows(rows, res)

		if _, ok := groupedByPrimary[res.Primary]; !ok {
			groupedByPrimary[res.Primary] = []*ResolveResult{}
		}

		groupedByPrimary[res.Primary] = append(groupedByPrimary[res.Primary], res)
	}

	results := []*AggregatedResult{}
	for k, v := range groupedByPrimary {
		res := &AggregatedResult{}
		res.Primary = k

		rank := float32(0)
		for _, r := range v {
			rel := AggregateRelated{}
			rel.Name = r.Related

			if r.Type == "" {
				rel.Rank += r.Rank
			} else if r.Type == "resources/related_names" {
				rel.Rank += r.Rank
			} else if r.Type == "resources/related_searches_goog" {
				rel.Rank += (r.Rank * 0.1)
			} else if r.Type == "resources/related_searches_bing" {
				rel.Rank += (r.Rank * 0.1)
			} else {
				return nil, fmt.Errorf("unknown related searches type: %v", r)
			}

			rank += rel.Rank

			res.Related = append(res.Related, rel)
		}

		res.Rank = rank

		results = append(results, res)
	}

	// sort in descending order
	sort.Slice(results, func(i, j int) bool {
		if results[i].Rank < results[j].Rank {
			return false
		}

		return true
	})

	return results, nil
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
		workout.Exercises[i] = e

		if _, err := ResolveHelper(db, e.Name); err != nil {
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}
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
