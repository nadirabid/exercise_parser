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

func PrettyStringify(v interface{}) string {
	b, err := prettyjson.Marshal(v)
	if err != nil {
		return "<COULD_NOT_STRINGIFY>"
	}

	return string(b)
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

func GetStringOrDefault(value string, defaultValue string) string {
	if value == "" {
		return defaultValue
	}

	return value
}

func SliceContainsString(slice []string, value string) bool {
	for _, str := range slice {
		if str == value {
			return true
		}
	}

	return false
}

func MaxInt(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func MaxFloat32(a, b float32) float32 {
	if a > b {
		return a
	}
	return b
}
