package cmd

import (
	"exercise_parser/models"
	"fmt"
	"sort"

	"github.com/spf13/cobra"
)

// TODO: this should just happen at the time of data collection - its bullshit for this to spread out
// through the data injection part of things
func sanitizeDictionaryMuscles(exerciseDictionary *models.ExerciseDictionary) error {
	target := []string{}
	for _, m := range exerciseDictionary.Muscles.Target {
		m = models.SanitizeMuscleString(m)
		if m == "" {
			continue
		}

		m, err := models.MuscleStandardName(m)
		if err != nil {
			return err
		}
		target = append(target, m)
	}
	exerciseDictionary.Muscles.Target = target

	synergists := []string{}
	for _, m := range exerciseDictionary.Muscles.Synergists {
		m = models.SanitizeMuscleString(m)
		if m == "" {
			continue
		}

		m, err := models.MuscleStandardName(m)
		if err != nil {
			return err
		}
		synergists = append(synergists, m)
	}
	exerciseDictionary.Muscles.Synergists = synergists

	stabilizers := []string{}
	for _, m := range exerciseDictionary.Muscles.Stabilizers {
		m = models.SanitizeMuscleString(m)
		if m == "" {
			continue
		}

		m, err := models.MuscleStandardName(m)
		if err != nil {
			return err
		}
		stabilizers = append(stabilizers, m)
	}
	exerciseDictionary.Muscles.Stabilizers = stabilizers

	antagonists := []string{}
	for _, m := range exerciseDictionary.Muscles.AntagonistStabilizers {
		m = models.SanitizeMuscleString(m)
		if m == "" {
			continue
		}

		m, err := models.MuscleStandardName(m)
		if err != nil {
			return err
		}
		antagonists = append(antagonists, m)
	}
	exerciseDictionary.Muscles.AntagonistStabilizers = antagonists

	dynamic := []string{}
	for _, m := range exerciseDictionary.Muscles.DynamicStabilizers {
		m = models.SanitizeMuscleString(m)
		if m == "" {
			continue
		}

		m, err := models.MuscleStandardName(m)
		if err != nil {
			return err
		}
		dynamic = append(dynamic, m)
	}
	exerciseDictionary.Muscles.DynamicStabilizers = dynamic

	dynamicArticulation := []string{}
	for _, m := range exerciseDictionary.Muscles.DynamicArticulation {
		m = models.SanitizeMuscleString(m)
		if m == "" {
			continue
		}

		m, err := models.MuscleStandardName(m)
		if err != nil {
			return err
		}
		dynamicArticulation = append(dynamicArticulation, m)
	}
	exerciseDictionary.Muscles.DynamicArticulation = dynamicArticulation

	staticArticulation := []string{}
	for _, m := range exerciseDictionary.Muscles.StaticArticulation {
		m = models.SanitizeMuscleString(m)
		if m == "" {
			continue
		}

		m, err := models.MuscleStandardName(m)
		if err != nil {
			return err
		}
		staticArticulation = append(staticArticulation, m)
	}
	exerciseDictionary.Muscles.StaticArticulation = staticArticulation

	return nil
}

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

func updateMusclesForDictionaries(cmd *cobra.Command, args []string) error {
	// init viper
	v, err := configureViperFromCmd(cmd)
	if err != nil {
		return err
	}

	// init db
	db, err := models.NewDatabase(v)
	if err != nil {
		return err
	}

}

var updateMusclesCmd = &cobra.Command{
	Use:   "update",
	Short: "Update muscles for dictionaries from resources",
	RunE:  updateMusclesForDictionaries,
}

var printMusclesCmd = &cobra.Command{
	Use:   "print",
	Short: "Print all muscles",
	RunE:  printMuscles,
}

var muscleCmd = &cobra.Command{
	Use:   "muscle",
	Short: "Print various diagnostics info",
}

func init() {
	dbCmd.AddCommand(muscleCmd)

	muscleCmd.AddCommand(updateMusclesCmd)
	muscleCmd.AddCommand(printMusclesCmd)
}
