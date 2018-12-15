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

// http://shisaa.jp/postset/postgresql-full-text-search-part-3.html

// NOTE: i'm seeding from locally stored files, because we're going to be seeding more
// than we should be hitting (by means of scrapping). allows for rapid nuking of the database
// without compromising on speed
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

		exerciseDictionary := &models.ExerciseDictionary{}
		json.Unmarshal(byteValue, &exerciseDictionary)

		if err := db.Create(exerciseDictionary).Error; err != nil {
			return fmt.Errorf("unable to save exercise type: %s", err.Error())
		}

		setTSV := `
			UPDATE exercise_dictionaries
			SET tsv=to_tsvector('english', coalesce(exercise_dictionaries.name, ''))
			WHERE id = ?
		`
		if err := db.Exec(setTSV, exerciseDictionary.ID).Error; err != nil {
			return fmt.Errorf("unable to set tsvector: %s", err.Error())
		}
	}

	fmt.Printf("seeded %d exercise types!\n", len(files))

	return nil
}

func drop(cmd *cobra.Command, args []string) error {
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

	// drop it all

	if err := db.Set("gorm:table_options", "CASCADE").DropTableIfExists(
		&models.ExerciseDictionary{},
	).Error; err != nil {
		return fmt.Errorf("couldn't drop table: %s", err.Error())
	}

	return nil
}

// startCmd represents the start command
var seedCmd = &cobra.Command{
	Use:   "seed",
	Short: "Seed the exercise dictionary",
	RunE:  seed,
}

var dropCmd = &cobra.Command{
	Use:   "drop",
	Short: "Drop the exercise dictionary",
	RunE:  drop,
}

var dictCmd = &cobra.Command{
	Use:   "dict",
	Short: "Commands to interact with dictionary",
}

func init() {
	rootCmd.AddCommand(dictCmd)

	dictCmd.AddCommand(seedCmd)
	seedCmd.Flags().String("conf", "dev", "The conf file name to use.")

	dictCmd.AddCommand(dropCmd)
	dropCmd.Flags().String("conf", "dev", "The conf file name to use.")
}
