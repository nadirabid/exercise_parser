package cmd

import (
	"encoding/json"
	"exercise_parser/models"
	"exercise_parser/utils"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"

	"github.com/jinzhu/gorm"

	"github.com/spf13/cobra"
)

func seedRelatedNames(db *gorm.DB, seedDir string) error {
	files, err := ioutil.ReadDir(seedDir)
	if err != nil {
		return err
	}

	for _, f := range files {
		file, err := os.Open(filepath.Join(seedDir, f.Name()))
		if err != nil {
			return err
		}
		defer file.Close()

		byteValue, _ := ioutil.ReadAll(file)

		related := relatedTerms{}
		json.Unmarshal(byteValue, &related)

		for _, r := range related.Related {
			m := &models.ExerciseRelatedName{}
			m.Primary = related.Name
			m.Related = r

			d := &models.ExerciseDictionary{}
			if db.Where("name = ?", m.Primary).First(d).RecordNotFound() {
				return fmt.Errorf("exercise_dictionary entry by name does not exist: %v", m)
			}

			if err := db.Create(m).Error; err != nil {
				fmt.Println("errored while saving", m)
				return fmt.Errorf("unable to save related name: %s", err.Error())
			}

			setTSV := `
				UPDATE exercise_related_names
				SET related_tsv=to_tsvector('english', coalesce(exercise_related_names.related, ''))
				WHERE id = ?
			`
			if err := db.Exec(setTSV, m.ID).Error; err != nil {
				return fmt.Errorf("unable to set tsvector: %s", err.Error())
			}
		}
	}

	return nil
}

// TODO: compile related names corpus
// 1. get related searches for every exercise name
// 2. filter out stop words
// 3. dump them into resources/related_searches
// 4. create table with exercise_name to related_searches
// 5. test!

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

	// seed exercises
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

		relatedName := &models.ExerciseRelatedName{}
		relatedName.Primary = exerciseDictionary.Name
		relatedName.Related = exerciseDictionary.Name

		if err := db.Create(relatedName).Error; err != nil {
			return fmt.Errorf("unable to save related name: %s", err.Error())
		}

		setTSV := `
			UPDATE exercise_related_names
			SET related_tsv=to_tsvector('english', coalesce(exercise_related_names.related, ''))
			WHERE id = ?
		`
		if err := db.Exec(setTSV, relatedName.ID).Error; err != nil {
			return fmt.Errorf("unable to set tsvector: %s", err.Error())
		}
	}
	fmt.Println("exercises seeding complete")

	// seed related names
	dir = v.GetString("resources.related_names_dir")

	if err := seedRelatedNames(db, dir); err != nil {
		return err
	}

	fmt.Println("related names seeding complete")

	// seed bing related searchs
	dir = v.GetString("resources.related_searches_bing_dir")

	if err := seedRelatedNames(db, dir); err != nil {
		return err
	}

	fmt.Println("bing related searches seeding complete")

	// seed goog related searchs
	dir = v.GetString("resources.related_searches_goog_dir")

	if err := seedRelatedNames(db, dir); err != nil {
		return err
	}

	fmt.Println("goog related searches seeding complete")

	return nil
}

func dump(cmd *cobra.Command, args []string) error {
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

	// start dump
	relatedMap := make(map[string][]string)

	rows, err := db.Model(&models.ExerciseRelatedName{}).Rows()
	if err != nil {
		return err
	}
	defer rows.Close()

	for rows.Next() {
		m := &models.ExerciseRelatedName{}
		db.ScanRows(rows, m)

		if m.Related == m.Primary {
			// no need to dump if related and primary are the same
			continue
		}

		relatedNames := []string{}
		if _, ok := relatedMap[m.Primary]; ok {
			relatedNames = relatedMap[m.Primary]
		}

		relatedMap[m.Primary] = append(relatedNames, m.Related)
	}

	for k, relatedNames := range relatedMap {
		r := &relatedTerms{}
		r.Name = k
		r.Related = relatedNames

		fileName := strings.ToLower(strings.Join(strings.Split(r.Name, " "), "_"))
		dir := v.GetString("resources.related_names_dir")

		utils.WriteToDir(r, fileName, dir)
	}

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
		&models.Joints{},
		&models.Classification{},
		&models.Muscles{},
		&models.Articulation{},
		&models.ExerciseRelatedName{},
		&models.ExerciseDictionary{},
	).Error; err != nil {
		return fmt.Errorf("couldn't drop table: %s", err.Error())
	}

	return nil
}

var seedCmd = &cobra.Command{
	Use:   "seed",
	Short: "Seed the exercise dictionary",
	RunE:  seed,
}

var dumpCmd = &cobra.Command{
	Use:   "dump",
	Short: "Dumps related names into JSON files",
	RunE:  dump,
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
	dictCmd.AddCommand(dumpCmd)
	dictCmd.AddCommand(dropCmd)
}
