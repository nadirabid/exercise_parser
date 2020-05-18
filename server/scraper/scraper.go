package scraper

import (
	"exercise_parser/models"
	"exercise_parser/utils"
	"fmt"
	"net"
	"net/http"
	"net/url"
	netURL "net/url"
	"regexp"
	"strings"
	"sync"
	"time"

	"github.com/PuerkitoBio/goquery"
	"github.com/fatih/color"
	"github.com/spf13/viper"

	"github.com/fatih/camelcase"
	"github.com/gocolly/colly"
)

var warner = color.New(color.FgYellow)
var errer = color.New(color.FgRed)
var successer = color.New(color.FgGreen)

// Scraper returns object that scrapes exrx.net
type Scraper struct {
	visitedURL                  map[string]bool
	visitedLock                 sync.RWMutex
	scraperWaitGroup            sync.WaitGroup
	exercisesOutputDirector     string
	articulationsOutputDirector string
	scrapedCount                int
}

// New returns a scraper object\
func New(v *viper.Viper) *Scraper {
	return &Scraper{
		visitedURL:                  make(map[string]bool),
		exercisesOutputDirector:     v.GetString("resources.dir.exercises"),
		articulationsOutputDirector: "resources/articulations",
		scrapedCount:                0,
	}
}

// Start gets the URLs we're interested in, and then traverses them
func (s *Scraper) Start(url string) {
	c := colly.NewCollector(
		colly.CacheDir("./scraper/.cache"),
		colly.AllowedDomains("exrx.net"),
	)

	c.Limit(&colly.LimitRule{DomainGlob: "*", Parallelism: 1})

	c.OnHTML("main article", func(e *colly.HTMLElement) {
		e.ForEach("a", func(_ int, el *colly.HTMLElement) {
			link, err := getURL(url, el.Attr("href"))
			if err != nil {
				fmt.Println("Error: ", err.Error())
			}

			s.visitedLock.Lock()
			if _, ok := s.visitedURL[link]; ok {
				s.visitedLock.Unlock()
				return
			}

			s.visitedURL[link] = true
			s.visitedLock.Unlock()

			if strings.Contains(link, "/WeightExercises/") ||
				strings.Contains(link, "/Aerobic/") ||
				strings.Contains(link, "/Plyometrics/") {
				time.Sleep(time.Millisecond * 50)
				s.scraperWaitGroup.Add(1)
				go s.ScrapeExercisePage(link)
			} else if !strings.Contains(link, "download_file") &&
				!strings.Contains(link, "Questions") &&
				!strings.Contains(link, "/Kinesiology/") &&
				!strings.Contains(link, "/Articulations/") &&
				!strings.Contains(link, "/Muscles/") &&
				!strings.Contains(link, "/Nutrition/") &&
				!strings.Contains(link, "/FlexFunction/") &&
				!strings.Contains(link, "/Testing/") &&
				!strings.Contains(link, "/Stretches/") &&
				!strings.Contains(link, "/Calculators/") {
				e.Request.Visit(link)
			}
		})
	})

	c.Visit(url)

	s.scraperWaitGroup.Wait()

	successer.Println("Completed: ", s.scrapedCount)
}

// ScrapeExercisePage will take the url and parse out the data
func (s *Scraper) ScrapeExercisePage(url string) {
	defer s.scraperWaitGroup.Done()

	if strings.Contains(url, "Stills") ||
		strings.Contains(url, "Lists") ||
		strings.Contains(url, "Injury") ||
		strings.Contains(url, "RunnersEdge") ||
		strings.Contains(url, "pdf") ||
		strings.Contains(url, "#") ||
		strings.Contains(url, "Tidbits") {
		fmt.Println("Ignoring: ", url)
		return
	}

	ignoreWrite := false
	exercise := &models.ExerciseDictionary{
		URL: url,
	}

	c := colly.NewCollector(
		colly.CacheDir("./scraper/.cache"),
	)

	c.WithTransport(&http.Transport{
		Proxy: http.ProxyFromEnvironment,
		DialContext: (&net.Dialer{
			Timeout:   30 * time.Second,
			KeepAlive: 30 * time.Second,
			DualStack: true,
		}).DialContext,
		MaxIdleConns:          1000,
		IdleConnTimeout:       90 * time.Second,
		TLSHandshakeTimeout:   10 * time.Second,
		ExpectContinueTimeout: 1 * time.Second,
	})

	c.OnRequest(func(r *colly.Request) {
		r.Headers.Set("User-Agent", randomString())
		r.Headers.Set("Referer", randomString())
	})

	c.OnHTML("h1.page-title", func(e *colly.HTMLElement) {
		exercise.Name = e.Text
	})

	// classification
	c.OnHTML("main.col-sm-9.Add-Margin-Bottom .row .col-sm-6:nth-child(1)", func(e *colly.HTMLElement) {
		e.ForEach("table tr", func(_ int, el *colly.HTMLElement) {
			title := strings.Trim(el.ChildText("td:first-child"), " ")
			switch title {
			case "Utility:":
				exercise.Classification.Utility = el.ChildText("td:nth-child(2)")
			case "Mechanics:":
				exercise.Classification.Mechanics = el.ChildText("td:nth-child(2)")
			case "Force:":
				exercise.Classification.Force = el.ChildText("td:nth-child(2)")
			case "Intensity:":
				exercise.Classification.Intensity = el.ChildText("td:nth-child(2)")
			case "Function:":
				exercise.Classification.Function = el.ChildText("td:nth-child(2)")
			case "Bearing:":
				exercise.Classification.Bearing = el.ChildText("td:nth-child(2)")
			case "Impact:":
				exercise.Classification.Impact = el.ChildText("td:nth-child(2)")
			default:
				warner.Println(url, "Unknown classification section: ", title)
			}
		})
	})

	// classification variant
	// Seems redundant but apparenlty sometimes the Classification table is in the right column
	// See: https://exrx.net/WeightExercises/DeltoidPosterior/DBLyingRearDeltRow
	c.OnHTML("main.col-sm-9.Add-Margin-Bottom .row .col-sm-6:nth-child(2)", func(e *colly.HTMLElement) {
		e.ForEach("table tr", func(_ int, el *colly.HTMLElement) {
			title := strings.Trim(el.ChildText("td:first-child"), " ")
			fmt.Println(url, "URL with strange pattern")
			switch title {
			case "Utility:":
				exercise.Classification.Utility = el.ChildText("td:nth-child(2)")
			case "Mechanics:":
				exercise.Classification.Mechanics = el.ChildText("td:nth-child(2)")
			case "Force:":
				exercise.Classification.Force = el.ChildText("td:nth-child(2)")
			case "Intensity:":
				exercise.Classification.Intensity = el.ChildText("td:nth-child(2)")
			case "Function:":
				exercise.Classification.Function = el.ChildText("td:nth-child(2)")
			case "Bearing:":
				exercise.Classification.Bearing = el.ChildText("td:nth-child(2)")
			case "Impact:":
				exercise.Classification.Impact = el.ChildText("td:nth-child(2)")
			default:
				warner.Println(url, "Unknown classification (variant) section: ", title)
			}
		})
	})

	// muscles
	c.OnHTML("main.col-sm-9.Add-Margin-Bottom .row .col-sm-6:nth-child(2)", func(e *colly.HTMLElement) {
		if !strings.Contains(e.DOM.Find("h2").Text(), "Muscles") {
			return
		}

		isMuscle := func(s string) bool {
			switch s {
			case "target":
				return true
			case "synergists":
				return true
			case "stabilizers":
				return true
			case "dynamicstabilizers":
				return true
			case "antagoniststabilizers":
				return true
			case "romcriteria":
				return true
			}

			return false
		}

		previousText := ""
		nowProcessingMuscles := false

		e.DOM.Children().Each(func(i int, s *goquery.Selection) {
			if isMuscle(previousText) {
				nowProcessingMuscles = true

				muscles := s.
					Find("li").
					Map(func(_ int, s *goquery.Selection) string {
						name := models.SanitizeMuscleString(s.Text())
						return name
					})

				switch previousText {
				case "target":
					exercise.Muscles.Target = muscles
				case "synergists":
					exercise.Muscles.Synergists = muscles
				case "stabilizers":
					exercise.Muscles.Stabilizers = muscles
				case "dynamicstabilizers":
					exercise.Muscles.DynamicStabilizers = muscles
				case "antagoniststabilizers":
					exercise.Muscles.AntagonistStabilizers = muscles
				case "romcriteria":
					exercise.Muscles.ROMCriteria = muscles
				}

				previousText = ""
			} else {
				current := sanitizeString(s.Text())

				if nowProcessingMuscles && !isMuscle(current) {
					warner.Println(url, "Expected to see type of muscle usage - but didn't: ", netURL.QueryEscape(current))
					previousText = ""
					nowProcessingMuscles = false
				} else if !isMuscle(current) {
					previousText = ""
				} else {
					previousText = current
				}
			}
		})
	})

	// articulation muscle redux
	c.OnHTML("main.col-sm-9.Add-Margin-Bottom .row .col-sm-6:nth-child(2)", func(e *colly.HTMLElement) {
		if !strings.Contains(e.DOM.Find("h2").Text(), "Force") {
			return
		}

		isArticulation := func(s string) bool {
			switch s {
			case "dynamic", "static":
				return true
			default:
				return false
			}
		}

		previousText := ""
		nowProcessingArticulation := false
		dynamicArticulation := map[string]bool{}
		staticArticulation := map[string]bool{}

		e.DOM.Children().Each(func(i int, sel *goquery.Selection) {
			if isArticulation(previousText) {
				nowProcessingArticulation = true

				var muscleNames []string
				sel.Find("li a").Each(func(_ int, sel *goquery.Selection) {
					articulationLink, _ := sel.Attr("href")
					link, err := getURL(url, articulationLink)
					if err != nil {
						fmt.Println("Error: ", err.Error())
					}

					addMuscleNames := s.ScrapeArticulations(link)
					muscleNames = append(muscleNames, addMuscleNames...)
				})

				switch previousText {
				case "dynamic":
					for _, m := range muscleNames {
						dynamicArticulation[m] = true
					}
				case "static":
					for _, m := range muscleNames {
						staticArticulation[m] = true
					}
				}

				previousText = ""
			} else {
				current := sanitizeString(sel.Text())

				if nowProcessingArticulation && !isArticulation(current) {
					warner.Println(url, "Expected to see type of articulation - but didn't: ", netURL.QueryEscape(current))
					previousText = ""
					nowProcessingArticulation = false
				} else if !isArticulation(current) {
					previousText = ""
				} else {
					previousText = current
				}
			}
		})

		dynamic := []string{}
		for k, _ := range dynamicArticulation {
			dynamic = append(dynamic, k)
		}
		exercise.Muscles.DynamicArticulation = dynamic

		static := []string{}
		for k, _ := range staticArticulation {
			static = append(static, k)
		}
		exercise.Muscles.StaticArticulation = static
	})

	// rule to figure out if we wanna ignore this page based on content
	c.OnHTML(".row.Breadcrumb-Container.Add-Margin-Top .col-sm-9", func(e *colly.HTMLElement) {
		if strings.Contains(e.Text, "> Article") || strings.Contains(e.Text, "> Data") {
			ignoreWrite = true
		}
	})

	c.OnError(func(r *colly.Response, err error) {
		errer.Println(url, "Error loading: ", err.Error())
	})

	if err := c.Visit(url); err != nil {
		errer.Println(url, err.Error())
		return
	}

	if ignoreWrite {
		fmt.Printf("Ignore scrapped page: %s\n", exercise.Name)
		return
	}

	fileName := strings.Replace(url, "https://exrx.net/", "", -1)
	fileName = strings.Replace(fileName, "http:__exrx.net", "", -1)
	fileName = strings.Replace(fileName, "/", "_", -1)
	fileName = strings.ToLower(fileName)

	if err := utils.WriteToDir(exercise, fileName, s.exercisesOutputDirector); err != nil {
		errer.Println(err.Error())
	}

	s.scrapedCount++
	successer.Println(url, "Completed!")
}

func (s *Scraper) ScrapeArticulations(url string) []string {
	c := colly.NewCollector(
		colly.CacheDir("./scraper/.cache"),
	)

	c.WithTransport(&http.Transport{
		Proxy: http.ProxyFromEnvironment,
		DialContext: (&net.Dialer{
			Timeout:   30 * time.Second,
			KeepAlive: 30 * time.Second,
			DualStack: true,
		}).DialContext,
		MaxIdleConns:          1000,
		IdleConnTimeout:       90 * time.Second,
		TLSHandshakeTimeout:   10 * time.Second,
		ExpectContinueTimeout: 1 * time.Second,
	})

	c.OnRequest(func(r *colly.Request) {
		r.Headers.Set("User-Agent", randomString())
		r.Headers.Set("Referer", randomString())
	})

	var muscles []string

	c.OnHTML("main article div.row > .col-sm-9", func(e *colly.HTMLElement) {
		nameAttr, _ := e.DOM.Find("p a").Attr("name")
		if !strings.Contains(url, nameAttr) { // only extract the part of the page the link points to
			return
		}

		muscles = e.DOM.Find("ul li a").Map(func(_ int, s *goquery.Selection) string {
			muscleLink, _ := s.Attr("href")
			muscleName := strings.Replace(muscleLink, "../Muscles/", "", -1)

			split := strings.ToLower(strings.Join(camelcase.Split(muscleName), " ")) // LikeThis -> like this

			return split
		})
	})

	if err := c.Visit(url); err != nil {
		errer.Println(url, err.Error())
		return []string{}
	}

	return muscles
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

func sanitizeString(m string) string {
	reg := regexp.MustCompile("[^a-zA-Z0-9]+")
	m = reg.ReplaceAllString(m, "")

	m = strings.ToLower(m)

	return m
}
