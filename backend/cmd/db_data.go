package cmd

import (
	"bufio"
	"encoding/json"
	"exercise_parser/models"
	"exercise_parser/utils"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"

	"github.com/jinzhu/gorm"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

func loadStopWords(v *viper.Viper) ([]string, error) {
	dir := v.GetString("resources.dir.stop_words")

	stopWords := []string{}

	files, err := ioutil.ReadDir(dir)
	if err != nil {
		return nil, err
	}

	for _, f := range files {
		file, err := os.Open(filepath.Join(dir, f.Name()))
		if err != nil {
			return nil, err
		}

		reader := bufio.NewReader(file)

		for {
			next, err := reader.ReadString('\n')
			if err == io.EOF {
				break
			} else if err != nil {
				return nil, err
			}

			next = strings.Trim(next, "\n")

			stopWords = append(stopWords, next, "")
		}

		file.Close()
	}

	return stopWords, nil
}

func seedRelatedNames(db *gorm.DB, seedDir string, stopWords []string) error {
	files, err := ioutil.ReadDir(seedDir)
	if err != nil {
		return err
	}

	for _, f := range files {
		file, err := os.Open(filepath.Join(seedDir, f.Name()))
		if err != nil {
			return err
		}

		byteValue, _ := ioutil.ReadAll(file)
		file.Close()

		related := relatedTerms{}
		json.Unmarshal(byteValue, &related)

		for _, r := range related.Related {
			m := &models.ExerciseRelatedName{}
			m.Related = sanitizeRelatedName(r)
			m.Type = seedDir

			// if, after removing stop words, we have an emptry string, then don't insert into db
			if m.Related == "" {
				continue
			}

			// check if related_tsv is already in tehre
			q := `
				SELECT related_tsv
				FROM exercise_related_names
				WHERE to_tsvector(?) = related_tsv
			`
			rows, err := db.Raw(q, m.Related).Rows()
			if err != nil {
				return err
			}

			if rows.Next() {
				rows.Close()
				continue
			}
			rows.Close()

			d := &models.ExerciseDictionary{}
			if db.Where("name = ?", related.Name).First(d).RecordNotFound() {
				// TODO: does check fucking work???
				return fmt.Errorf("exercise_dictionary entry by name does not exist: %v", m)
			}

			m.ExerciseDictionaryID = d.ID

			if err := db.Create(m).Error; err != nil {
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

func seedExercises(db *gorm.DB, seedDir string) error {
	files, err := ioutil.ReadDir(seedDir)
	if err != nil {
		return err
	}

	for _, f := range files {
		file, err := os.Open(filepath.Join(seedDir, f.Name()))
		if err != nil {
			return err
		}

		byteValue, _ := ioutil.ReadAll(file)
		file.Close()

		exerciseDictionary := &models.ExerciseDictionary{}
		json.Unmarshal(byteValue, &exerciseDictionary)

		if err := db.Create(exerciseDictionary).Error; err != nil {
			return fmt.Errorf("unable to save exercise type: %s", err.Error())
		}

		relatedName := &models.ExerciseRelatedName{}
		relatedName.Related = sanitizeRelatedName(exerciseDictionary.Name)
		relatedName.ExerciseDictionaryID = exerciseDictionary.ID
		relatedName.Type = "model"

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

	return nil
}

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

	fmt.Println("migration complete")

	stopWords, err := loadStopWords(v) // get stop words replacer
	if err != nil {
		return err
	}

	// seed exercises
	dir := v.GetString("resources.dir.exercises")

	if err := seedExercises(db, dir); err != nil {
		return err
	}

	fmt.Println("exercises seeding complete")

	// seed related names
	dir = v.GetString("resources.dir.related_names")

	if err := seedRelatedNames(db, dir, stopWords); err != nil {
		return err
	}

	fmt.Println("related names seeding complete")

	// seed bing related searchs
	dir = v.GetString("resources.dir.related_searches_bing")

	if err := seedRelatedNames(db, dir, stopWords); err != nil {
		return err
	}

	fmt.Println("bing related searches seeding complete")

	// seed goog related searchs
	dir = v.GetString("resources.dir.related_searches_goog")

	if err := seedRelatedNames(db, dir, stopWords); err != nil {
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
	relatedMap := make(map[uint][]string)

	rows, err := db.Model(&models.ExerciseRelatedName{}).Rows()
	if err != nil {
		return err
	}
	defer rows.Close()

	for rows.Next() {
		m := &models.ExerciseRelatedName{}
		db.ScanRows(rows, m)

		if m.Type == "model" {
			// no need to dump if related and primary are the same
			continue
		}

		relatedNames := []string{}
		if _, ok := relatedMap[m.ExerciseDictionaryID]; ok {
			relatedNames = relatedMap[m.ExerciseDictionaryID]
		}

		relatedMap[m.ExerciseDictionaryID] = append(relatedNames, m.Related)
	}

	for k, relatedNames := range relatedMap {
		r := &relatedTerms{}

		exerciseDictionary := &models.ExerciseDictionary{}
		err := db.
			Where("id = ?", k).
			First(exerciseDictionary).
			Error

		if err != nil {
			return err
		}

		r.Name = exerciseDictionary.Name
		r.Related = relatedNames

		fileName := strings.ToLower(strings.Join(strings.Split(r.Name, " "), "_"))
		dir := v.GetString("resources.dir.related_names")

		utils.WriteToDir(r, fileName, dir)
	}

	return nil
}

func dropDictionaryTables(cmd *cobra.Command, args []string) error {
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

func dropAllTables(cmd *cobra.Command, args []string) error {
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

	if err := models.DropAll(db); err != nil {
		return err
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

var dropDictCmd = &cobra.Command{
	Use:   "drop",
	Short: "Drop dictionary tables",
	RunE:  dropDictionaryTables,
}

var dictCmd = &cobra.Command{
	Use:   "dict",
	Short: "Commands to interact with dictionary",
}

var dropAllCmd = &cobra.Command{
	Use:   "drop",
	Short: "Drop all databases",
	RunE:  dropAllTables,
}

var dbCmd = &cobra.Command{
	Use:   "db",
	Short: "Commands to interact with database",
}

func init() {
	rootCmd.AddCommand(dbCmd)

	dbCmd.AddCommand(dictCmd)
	dbCmd.AddCommand(dropAllCmd)

	dictCmd.AddCommand(seedCmd)
	dictCmd.AddCommand(dumpCmd)
	dictCmd.AddCommand(dropDictCmd)
}
