package scraper

import (
	"exercise_parser/utils"

	"github.com/gocolly/colly"
	"github.com/spf13/viper"
)

//body > div.site-container > div.site-inner > div > main > article > div > ul > div > li:nth-child(1) > a > figure > figcaption > p

type SpotibiScraper struct {
	outputDirector string
}

// NewSpotibiScraper returns a scraper object\
func NewSpotibiScraper(v *viper.Viper) *SpotibiScraper {
	return &SpotibiScraper{
		outputDirector: "resources/spotibi_names",
	}
}

// Start scraping
func (s *SpotibiScraper) Start() {
	c := colly.NewCollector(
		colly.CacheDir("./scraper/.cache"),
	)

	type nameLinkPair struct {
		URL  string
		Name string
	}

	names := []*nameLinkPair{}

	c.OnHTML("body main > article > div > ul > div > li > a", func(e *colly.HTMLElement) {
		p := &nameLinkPair{}

		p.URL = e.Attr("href")

		e.ForEach("figure > figcaption > p", func(_ int, el *colly.HTMLElement) {
			p.Name = el.Text
		})

		names = append(names, p)
	})

	c.OnScraped(func(_ *colly.Response) {
		utils.WriteToDir(names, "names", s.outputDirector)
	})

	c.Visit("https://www.spotebi.com/exercise-guide/")
}
