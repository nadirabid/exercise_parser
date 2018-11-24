package scraper

import (
	"encoding/json"
	"fmt"
	"strings"

	"github.com/PuerkitoBio/goquery"

	"github.com/gocolly/colly"
)

type Muscles struct {
	Target             []string
	Synergists         []string
	Stabilizers        []string
	DynamicStabilizers []string
}

type Exercise struct {
	Name      string
	Utility   string
	Mechanics string
	Force     string
	Muscles   Muscles
}

func ScrapeExercisePage(url string) {
	exercise := &Exercise{}

	c := colly.NewCollector(colly.CacheDir("./scraper/.cache"))

	c.OnHTML("h1.page-title", func(e *colly.HTMLElement) {
		exercise.Name = e.Text
	})

	c.OnHTML("main.col-sm-9.Add-Margin-Bottom .row .col-sm-6:nth-child(1)", func(e *colly.HTMLElement) {
		e.ForEach("table tr", func(_ int, el *colly.HTMLElement) {
			title := strings.Trim(el.ChildText("td:first-child"), " ")
			switch title {
			case "Utility:":
				exercise.Utility = el.ChildText("td:nth-child(2)")
			case "Mechanics:":
				exercise.Mechanics = el.ChildText("td:nth-child(2)")
			case "Force:":
				exercise.Force = el.ChildText("td:nth-child(2)")
			default:
				fmt.Println("Unknown section: ", title)
			}
		})
	})

	c.OnHTML("main.col-sm-9.Add-Margin-Bottom .row .col-sm-6:nth-child(2)", func(e *colly.HTMLElement) {
		e.ForEach("p a", func(i int, el *colly.HTMLElement) {
			muscles := e.DOM.
				Find(fmt.Sprintf("ul:nth-of-type(%d) li a", i+1)).
				Map(func(_ int, s *goquery.Selection) string {
					return s.Text()
				})

			title := strings.Trim(el.Text, " ")
			switch title {
			case "Target":
				exercise.Muscles.Target = muscles
			case "Synergists":
				exercise.Muscles.Synergists = muscles
			case "Stabilizers":
				exercise.Muscles.Stabilizers = muscles
			case "Dynamic Stabilizers":
				exercise.Muscles.DynamicStabilizers = muscles
			default:
				fmt.Println("Unknown muscle section: ", title)
			}
		})
	})

	c.Visit(url)

	prettyPrint(exercise)
}

func prettyPrint(v interface{}) (err error) {
	b, err := json.MarshalIndent(v, "", "  ")
	if err != nil {
		fmt.Printf("prettyPrint: %v\n", err)
	}

	fmt.Println(string(b))

	return
}
