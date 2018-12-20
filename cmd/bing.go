package cmd

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"net/http"
	"strconv"

	"github.com/spf13/cobra"
)

func bing(cmd *cobra.Command, args []string) error {
	// https://stackoverflow.com/questions/24455147/how-do-i-send-a-json-string-in-a-post-request-in-go
	mkt := "en-US"
	mode := "proof"
	host := "https://api.cognitive.microsoft.com"
	path := "bing/v7.0/spellcheck"
	key := "0e15dce3bf544f6d9971eeda86c7c6d7"
	text := "tricep extentions"

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
	fmt.Println("response Body:", string(body))

	return nil
}

// startCmd represents the start command
var bingCmd = &cobra.Command{
	Use:   "bing",
	Short: "Start the server",
	RunE:  bing,
}

func init() {
	rootCmd.AddCommand(bingCmd)

	bingCmd.Flags().String("conf", "dev", "The conf file name to use.")
}
