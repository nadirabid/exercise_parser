package scraper

import (
	"exercise_parser/utils"
	"fmt"
	"math/rand"
	"net/http"
	"strings"

	"github.com/gocolly/colly"
	"github.com/spf13/viper"
)

const letterBytes = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

func randomString() string {
	b := make([]byte, rand.Intn(10)+10)
	for i := range b {
		b[i] = letterBytes[rand.Intn(len(letterBytes))]
	}
	return string(b)
}

// GoogScraper holds info
type GoogScraper struct {
	outputDir string
}

// NewGoogScraper create GoogScraper
func NewGoogScraper(v *viper.Viper) *GoogScraper {
	return &GoogScraper{
		outputDir: v.GetString("resources.related_searches_goog_dir"),
	}
}

// Start scraping!!
func (g *GoogScraper) Start(query string) {
	c := colly.NewCollector(
		colly.CacheDir("./scraper/.cache"),
	)

	type related struct {
		Name    string
		Related []string
	}

	r := related{}
	r.Name = query

	// #center_col > div:nth-child(3) > table > tbody > tr > td > p > a
	c.OnHTML("#center_col > div:nth-child(3) > table > tbody > tr > td > p > a", func(e *colly.HTMLElement) {
		r.Related = append(r.Related, e.Text)
	})

	c.OnRequest(func(r *colly.Request) {
		r.Headers.Set("User-Agent", randomString())
		r.Headers.Set("Referer", "https://notifications.google.com/")
	})

	c.OnScraped(func(_ *colly.Response) {
		fileName := strings.ToLower(strings.Join(strings.Split(r.Name, " "), "_"))
		if err := utils.WriteToDir(r, fileName, g.outputDir); err != nil {
			fmt.Println(err)
		}
	})

	c.OnError(func(r *colly.Response, e error) {
		panic(e.Error())
	})

	endpoint := "https://www.google.com/search"
	req, err := http.NewRequest("GET", endpoint, nil)
	if err != nil {
		panic(err)
	}

	q := req.URL.Query()
	q.Add("q", query)
	req.URL.RawQuery = q.Encode()

	c.Visit(req.URL.String())
}
