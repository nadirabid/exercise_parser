package cmd

import (
	"encoding/json"
	"exercise_parser/models"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
)

func seed(cmd *cobra.Command, args []string) error {
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

	models.Migrate(db)

	// seed
	dir := v.GetString("resources.exercises_dir")
	files, err := ioutil.ReadDir(dir)
	if err != nil {
		return err
	}

	for _, f := range files {
		file, err := os.Open(filepath.Join(dir, f.Name()))
		if err != nil {
			return err
		}
		defer file.Close()

		byteValue, _ := ioutil.ReadAll(file)

		exerciseType := &models.ExerciseType{}
		json.Unmarshal(byteValue, &exerciseType)

		if err := db.Create(exerciseType).Error; err != nil {
			return fmt.Errorf("unable to save exercise type: %v", err)
		}
	}

	return nil
}

// startCmd represents the start command
var seedCmd = &cobra.Command{
	Use:   "seed",
	Short: "Seed the database",
	RunE:  seed,
}

func init() {
	rootCmd.AddCommand(seedCmd)

	seedCmd.Flags().String("conf", "dev", "The conf file name to use.")
}
