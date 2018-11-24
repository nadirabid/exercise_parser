package cmd

import (
	"exercise_parser/scraper"

	"github.com/spf13/cobra"
)

func scrape(cmd *cobra.Command, args []string) error {
	scraper.ScrapeExercisePage(args[0])
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
