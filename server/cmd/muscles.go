package cmd

import (
	"exercise_parser/models"
	"fmt"
	"regexp"
	"strings"

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

	dictionaries := []models.ExerciseDictionary{}

	err = db.
		Preload("Classification").
		Preload("Muscles").
		Preload("Articulation").
		Preload("Articulation.Dynamic").
		Preload("Articulation.Static").
		Find(&dictionaries).
		Error

	if err != nil {
		return err
	}

	muscles := map[string]bool{}

	for _, d := range dictionaries {
		for _, m := range d.Muscles.Target {
			muscles[m] = true
		}

		for _, m := range d.Muscles.Synergists {
			muscles[m] = true
		}

		for _, m := range d.Muscles.Stabilizers {
			muscles[m] = true
		}

		for _, m := range d.Muscles.AntagonistStabilizers {
			muscles[m] = true
		}

		for _, m := range d.Muscles.DynamicStabilizers {
			muscles[m] = true
		}
	}

	fmt.Println("\n ALL MUSCLES \n")

	space := regexp.MustCompile(`\s+`)
	count := 0

	for m, _ := range muscles {
		m = strings.TrimSpace(m)
		m = space.ReplaceAllString(m, " ")
		if m != "" {
			fmt.Println(m)
			count++
		}
	}

	fmt.Println("\n Count:", count)
	return nil
}

var printMusclesCmd = &cobra.Command{
	Use:   "muscles",
	Short: "Print all muscles",
	RunE:  printMuscles,
}

var printCmd = &cobra.Command{
	Use:   "print",
	Short: "Print various diagnostics info",
}

func init() {
	rootCmd.AddCommand(printCmd)

	printCmd.AddCommand(printMusclesCmd)
}
