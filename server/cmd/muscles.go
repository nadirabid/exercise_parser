package cmd

import (
	"exercise_parser/models"
	"exercise_parser/utils"
	"fmt"
	"sort"

	"github.com/spf13/cobra"
)

func printMuscles(cmd *cobra.Command, args []string) error {
	v, err := configureViperFromCmd(cmd)
	if err != nil {
		return err
	}

	db, err := models.NewDatabase(v)
	if err != nil {
		return err
	}

	muscleModels := []models.Muscles{}

	err = db.
		Find(&muscleModels).
		Error

	if err != nil {
		return err
	}

	muscles := map[string]bool{}

	for _, d := range muscleModels {
		for _, m := range d.Target {
			m = models.SanitizeMuscleString(m)
			muscles[m] = true
		}

		for _, m := range d.Synergists {
			m = models.SanitizeMuscleString(m)
			muscles[m] = true
		}

		for _, m := range d.Stabilizers {
			m = models.SanitizeMuscleString(m)
			muscles[m] = true
		}

		for _, m := range d.AntagonistStabilizers {
			m = models.SanitizeMuscleString(m)
			muscles[m] = true
		}

		for _, m := range d.DynamicStabilizers {
			m = models.SanitizeMuscleString(m)
			muscles[m] = true
		}
	}

	musclesSlice := []string{}

	for m, _ := range muscles {
		if m != "" {
			musclesSlice = append(musclesSlice, m)
		}
	}

	sort.Strings(musclesSlice)

	fmt.Println("\n ALL MUSCLES \n")

	count := 0

	for _, m := range musclesSlice {
		if m != "" {
			fmt.Println(m)
			count++
		}
	}

	fmt.Println("\n Count:", count)
	return nil
}

func sanitizeMuscleNamesInDB(cmd *cobra.Command, args []string) error {
	v, err := configureViperFromCmd(cmd)
	if err != nil {
		return err
	}

	db, err := models.NewDatabase(v)
	if err != nil {
		return err
	}

	muscleModels := []models.Muscles{}

	err = db.
		Find(&muscleModels).
		Error

	if err != nil {
		return err
	}

	for _, muscleModel := range muscleModels {
		target := []string{}
		for _, m := range muscleModel.Target {
			m = models.SanitizeMuscleString(m)
			if m == "" {
				continue
			}

			m, err = models.MuscleStandardName(m)
			if err != nil {
				utils.PrettyPrint(muscleModel)
				return err
			}
			target = append(target, m)
		}
		muscleModel.Target = target

		synergists := []string{}
		for _, m := range muscleModel.Synergists {
			m = models.SanitizeMuscleString(m)
			if m == "" {
				continue
			}

			m, err = models.MuscleStandardName(m)
			if err != nil {
				utils.PrettyPrint(muscleModel)
				return err
			}
			synergists = append(synergists, m)
		}
		muscleModel.Synergists = synergists

		stabilizers := []string{}
		for _, m := range muscleModel.Stabilizers {
			m = models.SanitizeMuscleString(m)
			if m == "" {
				continue
			}

			m, err = models.MuscleStandardName(m)
			if err != nil {
				utils.PrettyPrint(muscleModel)
				return err
			}
			stabilizers = append(stabilizers, m)
		}
		muscleModel.Stabilizers = stabilizers

		antagonists := []string{}
		for _, m := range muscleModel.AntagonistStabilizers {
			m = models.SanitizeMuscleString(m)
			if m == "" {
				continue
			}

			m, err = models.MuscleStandardName(m)
			if err != nil {
				utils.PrettyPrint(muscleModel)
				return err
			}
			antagonists = append(antagonists, m)
		}
		muscleModel.AntagonistStabilizers = antagonists

		dynamic := []string{}
		for _, m := range muscleModel.DynamicStabilizers {
			m = models.SanitizeMuscleString(m)
			if m == "" {
				continue
			}

			m, err = models.MuscleStandardName(m)
			if err != nil {
				utils.PrettyPrint(muscleModel)
				return err
			}
			dynamic = append(dynamic, m)
		}

		if err := db.Save(&muscleModel).Error; err != nil {
			return err
		}
	}

	return nil
}

var printMusclesCmd = &cobra.Command{
	Use:   "print",
	Short: "Print all muscles",
	RunE:  printMuscles,
}

var sanitizeMusclesCmd = &cobra.Command{
	Use:   "sanitize",
	Short: "Sanitize muscle names in db",
	RunE:  sanitizeMuscleNamesInDB,
}

var muscleCmd = &cobra.Command{
	Use:   "muscle",
	Short: "Print various diagnostics info",
}

func init() {
	rootCmd.AddCommand(muscleCmd)

	muscleCmd.AddCommand(printMusclesCmd)
	muscleCmd.AddCommand(sanitizeMusclesCmd)
}
