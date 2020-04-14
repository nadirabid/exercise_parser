package utils

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"

	prettyjson "github.com/hokaccha/go-prettyjson"
)

// PrettyPrint to output as json
func PrettyPrint(v interface{}) (err error) {
	b, err := prettyjson.Marshal(v)
	if err != nil {
		fmt.Printf("prettyPrint: %v\n", err)
	}

	fmt.Println(string(b))

	return
}

// WriteToDir saves struct to specified folers as JSON files
func WriteToDir(s interface{}, fileName string, dir string) error {
	if _, err := os.Stat(dir); os.IsNotExist(err) {
		os.Mkdir(dir, os.ModePerm)
	}

	filename := fmt.Sprintf("%s/%s.json", dir, fileName)

	json, err := json.MarshalIndent(s, "", "  ")
	if err != nil {
		return err
	}

	err = ioutil.WriteFile(filename, json, 0644)
	if err != nil {
		return err
	}

	return nil
}
