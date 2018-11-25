package scraper

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/url"
	"strings"
	"sync"
	"time"

	"github.com/PuerkitoBio/goquery"

	"github.com/gocolly/colly"
)

// Muscles are the areas that a given exercise affects
type Muscles struct {
	Target                []string
	Synergists            []string
	Stabilizers           []string
	DynamicStabilizers    []string
	AntagonistStabilizers []string
	ROMCriteria           []string
}

// Exercise is a single exercise
type Exercise struct {
	URL       string
	Name      string
	Utility   string
	Mechanics string
	Force     string
	Muscles   Muscles
	CrawledAt time.Time
}

// Scraper returns object that scrapes exrx.net
type Scraper struct {
	visitedURL    map[string]bool
	visitedLock   *sync.RWMutex
	exercises     map[string]*Exercise
	exercisesLock *sync.Mutex
}

// New returns a scraper object
func New() *Scraper {
	return &Scraper{
		visitedURL:    make(map[string]bool),
		visitedLock:   &sync.RWMutex{},
		exercises:     make(map[string]*Exercise),
		exercisesLock: &sync.Mutex{},
	}
}

func (s *Scraper) ScrapeExercisePage(url string) {
	exercise := &Exercise{
		CrawledAt: time.Now(),
		URL:       url,
	}

	c := colly.NewCollector(
		colly.CacheDir("./scraper/.cache"),
	)

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

			replacer := strings.NewReplacer(" ", "", "\t", "", "\n", "")
			title := replacer.Replace(el.Text)
			switch title {
			case "Target":
				exercise.Muscles.Target = muscles
			case "Synergists":
				exercise.Muscles.Synergists = muscles
			case "Stabilizers":
				exercise.Muscles.Stabilizers = muscles
			case "DynamicStabilizers":
				exercise.Muscles.DynamicStabilizers = muscles
			case "AntagonistStabilizers":
				exercise.Muscles.AntagonistStabilizers = muscles
			case "ROMCriteria":
				exercise.Muscles.ROMCriteria = muscles
			default:
				fmt.Println("Unknown muscle section: ", title)
			}
		})
	})

	s.visitedLock.Lock()
	s.exercises[exercise.Name] = exercise
	s.visitedLock.Unlock()

	c.Visit(url)

	json, _ := json.MarshalIndent(exercise, "", "  ")
	filename := fmt.Sprintf("%s/%s.json", "resources/exercises", strings.ToLower(strings.Join(strings.Split(exercise.Name, " "), "_")))
	err := ioutil.WriteFile(filename, json, 0644)

	if err != nil {
		fmt.Println(err)
	}
}

// Crawl gets the URLs we're interested in, and then traverses them
func (s *Scraper) Crawl(url string) {
	c := colly.NewCollector(
		colly.CacheDir("./scraper/.cache"),
	)

	c.OnHTML("main article", func(e *colly.HTMLElement) {
		e.ForEach("a", func(_ int, el *colly.HTMLElement) {
			link, err := getURL(url, el.Attr("href"))
			if err != nil {
				fmt.Println("Error: ", err.Error())
			}

			s.visitedLock.RLock()
			_, ok := s.visitedURL[link]
			s.visitedLock.RUnlock()

			if ok {
				// ok means its in the visitedURL dictionary, SO I've visited it before
				return
			} else if strings.Contains(link, "ExList/") {
				e.Request.Visit(link)
			} else if strings.Contains(link, "/WeightExercises/") || strings.Contains(link, "/Aerobic/") {
				s.ScrapeExercisePage(link)
			} else {
				fmt.Println("Unknown link: ", link)
			}
		})
	})

	c.OnRequest(func(r *colly.Request) {
		s.visitedLock.Lock()
		defer s.visitedLock.Unlock()

		if _, ok := s.visitedURL[r.URL.String()]; ok {
			fmt.Println("Abort visiting url: ", r.URL.String())
			r.Abort()
		} else {
			s.visitedURL[r.URL.String()] = true
		}
	})

	c.Visit(url)
}

// WriteToDir saves exerices to specified folers as JSON files
func (s *Scraper) WriteToDir(dir string) error {
	for k, v := range s.exercises {
		json, _ := json.Marshal(v)
		filename := fmt.Sprintf("%s/%s", dir, strings.ToLower(strings.Join(strings.Split(k, " "), "_")))
		err := ioutil.WriteFile(filename, json, 0644)

		if err != nil {
			return err
		}
	}

	return nil
}

func getURL(current string, path string) (string, error) {
	u, err := url.Parse(path)
	if err != nil {
		return "", err
	}

	currentURL, err := url.Parse(current)
	if err != nil {
		return "", err
	}

	return currentURL.ResolveReference(u).String(), nil
}

func prettyPrint(v interface{}) (err error) {
	b, err := json.MarshalIndent(v, "", "  ")
	if err != nil {
		fmt.Printf("prettyPrint: %v\n", err)
	}

	fmt.Println(string(b))

	return
}