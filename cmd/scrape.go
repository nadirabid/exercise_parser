package cmd

import (
	"exercise_parser/scraper"

	"github.com/spf13/cobra"
)

func scrape(cmd *cobra.Command, args []string) error {
	s := scraper.New()

	s.Crawl("https://exrx.net/Lists/Directory")
	s.WriteToDir("resources/exercises")

	return nil
}

var scrapeCmd = &cobra.Command{
	Use:   "scrape",
	Short: "Scrape url",
	RunE:  scrape,
}

func init() {
	rootCmd.AddCommand(scrapeCmd)
}
