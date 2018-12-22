package cmd

import (
	"bytes"
	"encoding/json"
	"errors"
	"exercise_parser/models"
	"exercise_parser/utils"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/spf13/cobra"
)

func scrapeRelatedSearches(cmd *cobra.Command, args []string) error {
	// init viper
	v, err := configureViperFromCmd(cmd)
	if err != nil {
		return err
	}

	endpoint := "https://api.cognitive.microsoft.com/bing/v7.0/search"
	key := "a67f95eca5ab4c43a07733c6882653a5"

	dir := v.GetString("resources.exercises_dir")
	files, err := ioutil.ReadDir(dir)
	if err != nil {
		return err
	}

	outDir := v.GetString("resources.related_searches_bing_dir")

	for _, f := range files {
		// open up exercise file to determine the name

		file, err := os.Open(filepath.Join(dir, f.Name()))
		if err != nil {
			return err
		}
		defer file.Close()

		byteValue, _ := ioutil.ReadAll(file)

		exerciseDictionary := &models.ExerciseDictionary{}
		json.Unmarshal(byteValue, &exerciseDictionary)

		// ask bing for related search terms

		req, err := http.NewRequest("GET", endpoint, nil)
		if err != nil {
			return err
		}

		param := req.URL.Query()
		param.Add("q", exerciseDictionary.Name)
		req.URL.RawQuery = param.Encode()
		req.Header.Add("Ocp-Apim-Subscription-Key", key)

		client := http.Client{}

		resp, err := client.Do(req)
		if err != nil {
			return err
		}

		defer resp.Body.Close()
		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			return err
		}

		res := bingAnswer{}
		err = json.Unmarshal(body, &res)
		if err != nil {
			return err
		}

		related := &relatedTerms{}
		related.Name = exerciseDictionary.Name
		for _, r := range res.RelatedSearches.Value {
			related.Related = append(related.Related, r.Text)
		}

		fileName := strings.ToLower(strings.Join(strings.Split(exerciseDictionary.Name, " "), "_"))
		if err := utils.WriteToDir(related, fileName, outDir); err != nil {
			fmt.Println(err.Error())
		}
	}

	return nil
}

func relatedSearches(cmd *cobra.Command, args []string) error {
	if len(args) == 0 {
		return errors.New("must specify string arguments")
	}

	endpoint := "https://api.cognitive.microsoft.com/bing/v7.0/search"
	key := "a67f95eca5ab4c43a07733c6882653a5"
	searchTerm := strings.Join(args, " ")

	// Declare a new GET request.
	req, err := http.NewRequest("GET", endpoint, nil)
	if err != nil {
		panic(err)
	}

	// Add the payload to the request.
	param := req.URL.Query()
	param.Add("q", searchTerm)
	req.URL.RawQuery = param.Encode()

	// Insert the request header.
	req.Header.Add("Ocp-Apim-Subscription-Key", key)

	// Create a new client.
	client := new(http.Client)

	// Send the request to Bing.
	resp, err := client.Do(req)
	if err != nil {
		return err
	}

	// Close the response.
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	// Create a new answer.
	res := bingAnswer{}
	err = json.Unmarshal(body, &res)
	if err != nil {
		return err
	}

	relatedSearches := []string{}
	for _, r := range res.RelatedSearches.Value {
		relatedSearches = append(relatedSearches, r.Text)
	}

	utils.PrettyPrint(relatedSearches)

	return nil
}

func spellcheck(cmd *cobra.Command, args []string) error {
	if len(args) == 0 {
		return fmt.Errorf("Specify string you'd like to spellcheck")
	}

	// https://stackoverflow.com/questions/24455147/how-do-i-send-a-json-string-in-a-post-request-in-go
	mkt := "en-US"
	mode := "proof"
	host := "https://api.cognitive.microsoft.com"
	path := "bing/v7.0/spellcheck"
	key := "0e15dce3bf544f6d9971eeda86c7c6d7"
	text := strings.Join(args, " ")

	url := fmt.Sprintf("%s/%s?mkt=%s&mode=%s", host, path, mkt, mode)

	req, err := http.NewRequest("POST", url, bytes.NewBuffer([]byte(fmt.Sprintf("text=%s", text))))
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	req.Header.Set("Content-Length", strconv.Itoa(len(text)+5))
	req.Header.Set("Ocp-Apim-Subscription-Key", key)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	body, _ := ioutil.ReadAll(resp.Body)

	type BingSpellCheck struct {
		FlaggedToken []struct {
			Offset      int    `json:"offset"`
			Token       string `json:"token"`
			Type        string `json:"type"`
			Suggestions []struct {
				Suggestion string  `json:"suggestion"`
				Scope      float32 `json:"score"`
			} `json:"suggestions"`
		} `json:"flaggedTokens"`
	}

	r := BingSpellCheck{}
	json.Unmarshal(body, &r)

	utils.PrettyPrint(r)

	return nil
}

var scrapeRelatedCmd = &cobra.Command{
	Use:   "scrape",
	Short: "scrape related searches",
	RunE:  scrape,
}

var relatedCmd = &cobra.Command{
	Use:   "related",
	Short: "get relates searches",
	RunE:  relatedSearches,
}

var spellcheckCmd = &cobra.Command{
	Use:   "spellcheck",
	Short: "spell correction suggestions",
	RunE:  spellcheck,
}

// startCmd represents the start command
var bingCmd = &cobra.Command{
	Use:   "bing",
	Short: "test bing APIs",
}

func init() {
	rootCmd.AddCommand(bingCmd)

	bingCmd.AddCommand(spellcheckCmd)
	bingCmd.AddCommand(relatedCmd)
	bingCmd.AddCommand(scrapeRelatedCmd)
}
