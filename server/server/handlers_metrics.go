package server

import (
	"exercise_parser/models"
	"exercise_parser/utils"
	"fmt"
	"net/http"
	"strconv"

	"github.com/labstack/echo"
)

func handleGetMetrics(c echo.Context) error {
	ctx := c.(*Context)
	db := ctx.db

	pastDays, err := strconv.Atoi(utils.GetStringOrDefault(ctx.QueryParam("pastDays"), "7"))
	if err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	if pastDays > 90 {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	userID := getUserIDFromContext(ctx)

	metrics := []models.Metric{}

	err = db.
		Preload("Muscles").
		Preload("TopLevel").
		Joins("JOIN workouts ON workouts.id = metrics.workout_id").
		Where(fmt.Sprintf("workouts.created_at > current_date - INTERVAL '%d' day AND workouts.user_id = ?", pastDays), userID).
		Find(&metrics).
		Error

	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	response := models.Metric{
		Muscles: []models.MetricMuscle{},
	}

	repsByTargetMuscles := map[string]int{}
	repsBySynergistMuscles := map[string]int{}
	repsByStabilizerMuscles := map[string]int{}
	repsByDynamicStabilizerMuscles := map[string]int{}
	repsByAntagonistStabilizerMuscles := map[string]int{}
	repsByDynamicArticulationMuscles := map[string]int{}
	repsByStaticArticulationMuscles := map[string]int{}

	for _, metric := range metrics {
		response.TopLevel.Sets += metric.TopLevel.Sets
		response.TopLevel.Reps += metric.TopLevel.Reps
		response.TopLevel.Distance += metric.TopLevel.Distance
		response.TopLevel.SecondsElapsed += metric.TopLevel.SecondsElapsed
		response.TopLevel.Calories += metric.TopLevel.Calories

		for _, muscle := range metric.Muscles {
			switch muscle.Usage {
			case models.TargetMuscle:
				repsByTargetMuscles[muscle.Name] += muscle.Reps
			case models.SynergistMuscle:
				repsBySynergistMuscles[muscle.Name] += muscle.Reps
			case models.StabilizerMuscle:
				repsByStabilizerMuscles[muscle.Name] += muscle.Reps
			case models.DynamicStabilizerMuscle:
				repsByDynamicStabilizerMuscles[muscle.Name] += muscle.Reps
			case models.AntagonistStabilizerMuscle:
				repsByAntagonistStabilizerMuscles[muscle.Name] += muscle.Reps
			case models.DynamicArticulationMuscle:
				repsByDynamicArticulationMuscles[muscle.Name] += muscle.Reps
			}
		}
	}

	for name, reps := range repsByTargetMuscles {
		response.Muscles = append(response.Muscles, models.MetricMuscle{
			Name:  name,
			Reps:  reps,
			Usage: models.TargetMuscle,
		})
	}

	for name, reps := range repsBySynergistMuscles {
		response.Muscles = append(response.Muscles, models.MetricMuscle{
			Name:  name,
			Reps:  reps,
			Usage: models.SynergistMuscle,
		})
	}

	for name, reps := range repsByStabilizerMuscles {
		response.Muscles = append(response.Muscles, models.MetricMuscle{
			Name:  name,
			Reps:  reps,
			Usage: models.StabilizerMuscle,
		})
	}

	for name, reps := range repsByDynamicStabilizerMuscles {
		response.Muscles = append(response.Muscles, models.MetricMuscle{
			Name:  name,
			Reps:  reps,
			Usage: models.DynamicStabilizerMuscle,
		})
	}

	for name, reps := range repsByAntagonistStabilizerMuscles {
		response.Muscles = append(response.Muscles, models.MetricMuscle{
			Name:  name,
			Reps:  reps,
			Usage: models.AntagonistStabilizerMuscle,
		})
	}

	for name, reps := range repsByDynamicArticulationMuscles {
		response.Muscles = append(response.Muscles, models.MetricMuscle{
			Name:  name,
			Reps:  reps,
			Usage: models.DynamicArticulationMuscle,
		})
	}

	for name, reps := range repsByStaticArticulationMuscles {
		response.Muscles = append(response.Muscles, models.MetricMuscle{
			Name:  name,
			Reps:  reps,
			Usage: models.StaticArticulationMuscle,
		})
	}

	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, response)
}
