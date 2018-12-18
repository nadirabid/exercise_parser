package scraper

import (
	"exercise_parser/models"
	"exercise_parser/utils"
	"fmt"
	"net/url"
	"strings"
	"sync"

	"github.com/PuerkitoBio/goquery"
	"github.com/spf13/viper"

	"github.com/gocolly/colly"
)

// Scraper returns object that scrapes exrx.net
type Scraper struct {
	visitedURL       map[string]bool
	visitedLock      sync.RWMutex
	scraperWaitGroup sync.WaitGroup
	outputDirector   string
}

// New returns a scraper object\
func New(v *viper.Viper) *Scraper {
	return &Scraper{
		visitedURL:     make(map[string]bool),
		outputDirector: v.GetString("resources.exercises_dir"),
	}
}

// Start gets the URLs we're interested in, and then traverses them
func (s *Scraper) Start(url string) {
	c := colly.NewCollector(
		colly.CacheDir("./scraper/.cache"),
		colly.AllowedDomains("exrx.net"),
	)

	c.Limit(&colly.LimitRule{DomainGlob: "*", Parallelism: 100})

	c.OnHTML("main article", func(e *colly.HTMLElement) {
		e.ForEach("a", func(_ int, el *colly.HTMLElement) {
			link, err := getURL(url, el.Attr("href"))
			if err != nil {
				fmt.Println("Error: ", err.Error())
			}

			s.visitedLock.Lock()
			if _, ok := s.visitedURL[link]; ok {
				//fmt.Println("Alredy visited: ", link)
				s.visitedLock.Unlock()
				return
			} else {
				s.visitedURL[link] = true
				s.visitedLock.Unlock()
			}

			if strings.Contains(link, "/WeightExercises/") ||
				strings.Contains(link, "/Aerobic/") ||
				strings.Contains(link, "/Plyometrics/") {
				s.scraperWaitGroup.Add(1)
				go s.ScrapeExercisePage(link)
			} else if !strings.Contains(link, "download_file") ||
				!strings.Contains(link, "Questions") {
				e.Request.Visit(link)
			}
		})
	})

	c.Visit(url)
	s.scraperWaitGroup.Wait()
}

// ScrapeExercisePage will take the url and parse out the data
func (s *Scraper) ScrapeExercisePage(url string) {
	defer s.scraperWaitGroup.Done()

	if strings.Contains(url, "Stills") || strings.Contains(url, "Lists") {
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

	c.OnHTML("h1.page-title", func(e *colly.HTMLElement) {
		exercise.Name = e.Text
	})

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
				fmt.Printf("Unknown section %s at %s \n", title, url)
			}
		})
	})

	// Seems redundant but apparenlty sometimes the Classification table is in the right column
	// See: https://exrx.net/WeightExercises/DeltoidPosterior/DBLyingRearDeltRow
	c.OnHTML("main.col-sm-9.Add-Margin-Bottom .row .col-sm-6:nth-child(2)", func(e *colly.HTMLElement) {
		e.ForEach("table tr", func(_ int, el *colly.HTMLElement) {
			title := strings.Trim(el.ChildText("td:first-child"), " ")
			fmt.Println("URL with strange pattern", url)
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
				fmt.Printf("Unknown section %s at %s \n", title, url)
			}
		})
	})

	c.OnHTML("main.col-sm-9.Add-Margin-Bottom .row .col-sm-6:nth-child(2)", func(e *colly.HTMLElement) {
		if !strings.Contains(e.DOM.Find("h2").Text(), "Muscles") {
			return
		}

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
				fmt.Printf("Unknow muscle section %s at %s\n", title, url)
			}
		})
	})

	c.OnHTML("main.col-sm-9.Add-Margin-Bottom .row .col-sm-6:nth-child(2)", func(e *colly.HTMLElement) {
		if !strings.Contains(e.DOM.Find("h2").First().Text(), "Force") {
			return
		}

		e.ForEach("p strong", func(i int, el *colly.HTMLElement) {
			jointTypes := models.Joints{}
			e.DOM.
				Find(fmt.Sprintf("p + ul:nth-of-type(%d) > li", i+1)).
				Each(func(_ int, s *goquery.Selection) {
					name := s.Contents().
						FilterFunction(func(_ int, s *goquery.Selection) bool {
							if goquery.NodeName(s) == "#text" {
								return true
							}

							return false
						}).
						Text()

					replacer := strings.NewReplacer(" ", "", "\t", "", "\n", "")
					name = replacer.Replace(name)

					joints := s.
						Find("ul li").
						Map(func(_ int, s *goquery.Selection) string {
							return s.Text()
						})

					if strings.Contains(name, "Ankle") {
						jointTypes.Ankle = []string{}
						jointTypes.Ankle = append(jointTypes.Ankle, joints...)
					} else if strings.Contains(name, "Elbow") {
						jointTypes.Elbow = []string{}
						jointTypes.Elbow = append(jointTypes.Elbow, joints...)
					} else if strings.Contains(name, "Finger") {
						jointTypes.Finger = []string{}
						jointTypes.Finger = append(jointTypes.Finger, joints...)
					} else if strings.Contains(name, "Foot") {
						jointTypes.Foot = []string{}
						jointTypes.Foot = append(jointTypes.Foot, joints...)
					} else if strings.Contains(name, "Forearm") {
						jointTypes.Forearms = []string{}
						jointTypes.Forearms = append(jointTypes.Forearms, joints...)
					} else if strings.Contains(name, "Hip") {
						jointTypes.Hip = []string{}
						jointTypes.Hip = append(jointTypes.Hip, joints...)
					} else if strings.Contains(name, "Scapula") {
						jointTypes.Scapula = []string{}
						jointTypes.Scapula = append(jointTypes.Scapula, joints...)
					} else if strings.Contains(name, "ShoulderGridle") {
						jointTypes.ShoulderGirdle = []string{}
						jointTypes.ShoulderGirdle = append(jointTypes.ShoulderGirdle, joints...)
					} else if strings.Contains(name, "Shoulder") {
						jointTypes.Shoulder = []string{}
						jointTypes.Shoulder = append(jointTypes.Shoulder, joints...)
					} else if strings.Contains(name, "Spine") {
						jointTypes.Spine = []string{}
						jointTypes.Spine = append(jointTypes.Spine, joints...)
					} else if strings.Contains(name, "Thumb") {
						jointTypes.Thumb = []string{}
						jointTypes.Thumb = append(jointTypes.Thumb, joints...)
					} else if strings.Contains(name, "Wrist") {
						jointTypes.Wrist = []string{}
						jointTypes.Wrist = append(jointTypes.Wrist, joints...)
					} else if strings.Contains(name, "Knee") {
						jointTypes.Knee = []string{}
						jointTypes.Knee = append(jointTypes.Knee, joints...)
					} else {
						fmt.Println("Unknown joint type: ", name)
					}
				})

			section := el.Text
			switch section {
			case "Dynamic":
				exercise.Articulation.Dynamic = jointTypes
			case "Static":
				exercise.Articulation.Static = jointTypes
			default:
				fmt.Printf("Unknow articulation section %s at %s\n", section, url)
			}
		})
	})

	c.OnHTML(".row.Breadcrumb-Container.Add-Margin-Top .col-sm-9", func(e *colly.HTMLElement) {
		if strings.Contains(e.Text, "> Article") || strings.Contains(e.Text, "> Data") {
			ignoreWrite = true
		}
	})

	c.OnError(func(r *colly.Response, err error) {
		fmt.Printf("Error loading %s: %s\n", url, err.Error())
	})

	if err := c.Visit(url); err != nil {
		fmt.Println(err.Error())
		return
	}

	if ignoreWrite {
		fmt.Printf("Ignore scrapped page: %s\n", exercise.Name)
		return
	}

	fileName := strings.ToLower(strings.Join(strings.Split(exercise.Name, " "), "_"))

	if err := utils.WriteToDir(exercise, fileName, s.outputDirector); err != nil {
		fmt.Println(err.Error())
	}
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
