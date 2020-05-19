package cmd

import (
	"encoding/json"
	"exercise_parser/models"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"sort"
	"strings"

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

	successer.Println("\n ALL MUSCLES \n")

	count := 0

	for _, m := range musclesSlice {
		if m != "" {
			fmt.Println(m)
			count++
		}
	}

	successer.Println("\n Count:", count)
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

	dir := v.GetString("resources.dir.exercises")
	files, err := ioutil.ReadDir(dir)
	if err != nil {
		return err
	}

	for _, f := range files {
		file, err := os.Open(filepath.Join(dir, f.Name()))
		if err != nil {
			return err
		}

		byteValue, _ := ioutil.ReadAll(file)
		file.Close()

		exerciseDictionary := &models.ExerciseDictionary{}
		json.Unmarshal(byteValue, &exerciseDictionary)

		sanitizeDictionaryMuscles(exerciseDictionary)

		q := db.
			Joins("JOIN exercise_dictionaries ON exercise_dictionaries.id = muscles.exercise_dictionary_id").
			Where("exercise_dictionaries.url = ?", exerciseDictionary.URL)

		m := &models.Muscles{}

		if err := q.First(m).Error; err != nil {
			if strings.Contains(err.Error(), "record not found") {
				warner.Println("Unable to find dictionary with URL (probably a dupe with same name): ", exerciseDictionary.URL)
				continue
			}

			return err
		}

		m.Target = exerciseDictionary.Muscles.Target
		m.Synergists = exerciseDictionary.Muscles.Synergists
		m.Stabilizers = exerciseDictionary.Muscles.Stabilizers
		m.DynamicStabilizers = exerciseDictionary.Muscles.DynamicStabilizers
		m.AntagonistStabilizers = exerciseDictionary.Muscles.AntagonistStabilizers
		m.ROMCriteria = exerciseDictionary.Muscles.ROMCriteria
		m.DynamicArticulation = exerciseDictionary.Muscles.DynamicArticulation
		m.StaticArticulation = exerciseDictionary.Muscles.StaticArticulation

		if err := db.Save(m).Error; err != nil {
			return err
		}
	}

	return nil
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
