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

func scrapeExrx(cmd *cobra.Command, args []string) error {
	v, err := configureViperFromCmd(cmd)
	if err != nil {
		return err
	}

	s := scraper.New(v)
	s.Start("https://exrx.net/Lists/Directory")

	return nil
}

func scrapeGoog(cmd *cobra.Command, args []string) error {
	v, err := configureViperFromCmd(cmd)
	if err != nil {
		return err
	}

	s := scraper.NewGoogScraper(v)

	dir := v.GetString("resources.dir.exercises")
	files, err := ioutil.ReadDir(dir)
	if err != nil {
		return err
	}

	for _, f := range files {
		outDir := v.GetString("resources.dir.related_searches_goog")

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

var scrapeGoogCmd = &cobra.Command{
	Use:   "goog",
	Short: "Scrape goog",
	RunE:  scrapeGoog,
}

var scrapeExrxCmd = &cobra.Command{
	Use:   "exrx",
	Short: "Scrape exrx",
	RunE:  scrapeExrx,
}

var scrapeCmd = &cobra.Command{
	Use:   "scrape",
	Short: "various scrapers useful for getting data for this app",
}

func init() {
	rootCmd.AddCommand(scrapeCmd)

	scrapeCmd.AddCommand(scrapeExrxCmd)
	scrapeCmd.AddCommand(scrapeGoogCmd)
}
