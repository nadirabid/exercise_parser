package cmd

import (
	"encoding/json"
	"exercise_parser/models"
	"exercise_parser/scraper"
	"io/ioutil"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
)

func scrape(cmd *cobra.Command, args []string) error {
	v, err := configureViperFromCmd(cmd)
	if err != nil {
		return err
	}

	s := scraper.New(v)
	s.Start("https://exrx.net/Lists/Directory")

	return nil
}

func test(cmd *cobra.Command, args []string) error {
	v, err := configureViperFromCmd(cmd)
	if err != nil {
		return err
	}

	s := scraper.NewGoogScraper(v)

	dir := v.GetString("resources.exercises_dir")
	files, err := ioutil.ReadDir(dir)
	if err != nil {
		return err
	}

	for _, f := range files {
		outDir := v.GetString("resources.related_searches_goog_dir")

		if _, err := os.Stat(filepath.Join(outDir, f.Name())); !os.IsNotExist(err) {
			continue
		}

		file, err := os.Open(filepath.Join(dir, f.Name()))
		if err != nil {
			return err
		}
		defer file.Close()

		byteValue, _ := ioutil.ReadAll(file)

		exerciseDictionary := &models.ExerciseDictionary{}
		json.Unmarshal(byteValue, &exerciseDictionary)

		s.Start(exerciseDictionary.Name)
	}

	return nil
}

var testCmd = &cobra.Command{
	Use:   "test",
	Short: "test",
	RunE:  test,
}

var scrapeCmd = &cobra.Command{
	Use:   "scrape",
	Short: "Scrape url",
	RunE:  scrape,
}

func init() {
	rootCmd.AddCommand(scrapeCmd)
	rootCmd.AddCommand(testCmd)
}
