package cmd

import (
	"exercise_parser/scraper"

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

func scrape2(cmd *cobra.Command, args []string) error {
	v, err := configureViperFromCmd(cmd)
	if err != nil {
		return err
	}

	s := scraper.NewSpotibiScraper(v)
	s.Start()

	return nil
}

var scrapeCmd = &cobra.Command{
	Use:   "scrape",
	Short: "Scrape url",
	RunE:  scrape,
}

func init() {
	rootCmd.AddCommand(scrapeCmd)
	scrapeCmd.Flags().String("conf", "dev", "The conf file name to use.")
}
