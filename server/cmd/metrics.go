package cmd

import (
	"exercise_parser/metrics"
	"exercise_parser/models"

	"github.com/spf13/cobra"
)

func computeMetricsForAllWorkouts(cmd *cobra.Command, args []string) error {
	v, err := configureViperFromCmd(cmd)
	if err != nil {
		return err
	}

	db, err := models.NewDatabase(v)
	if err != nil {
		return err
	}

	workouts := []models.Workout{}

	err = db.
		Where(`workouts.id NOT IN (SELECT metrics.workout_id FROM metrics)`).
		Find(&workouts).
		Error

	if err != nil {
		return err
	}

	for _, w := range workouts {
		if err := metrics.ComputeForWorkout(w.ID, db); err != nil {
			return err
		}
	}

	return nil
}

// delete and recompute all metrics
func recomputeMetricsForAllWorkouts(cmd *cobra.Command, args []string) error {
	v, err := configureViperFromCmd(cmd)
	if err != nil {
		return err
	}

	db, err := models.NewDatabase(v)
	if err != nil {
		return err
	}

	err = db.
		Where(`workouts.id NOT IN (SELECT metrics.workout_id FROM metrics)`).
		Delete(models.Workout{}).
		Error

	if err != nil {
		return err
	}

	return computeMetricsForAllWorkouts(cmd, args)
}

var recomputeMetricsCmd = &cobra.Command{
	Use:   "recompute",
	Short: "Recompute metrics for all workouts",
	RunE:  recomputeMetricsForAllWorkouts,
}

var computeMetricsCmd = &cobra.Command{
	Use:   "compute",
	Short: "Compute metrics for all workouts",
	RunE:  computeMetricsForAllWorkouts,
}

var metricsCmd = &cobra.Command{
	Use:   "metrics",
	Short: "Commands for messing with metrics",
}

func init() {
	rootCmd.AddCommand(metricsCmd)

	metricsCmd.AddCommand(computeMetricsCmd)
	metricsCmd.AddCommand(recomputeMetricsCmd)
}
