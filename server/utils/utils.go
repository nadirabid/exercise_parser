package utils

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"path"
	"path/filepath"
	"runtime"
	"strings"

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

var (
	_, b, _, _ = runtime.Caller(0)
	basePath   = filepath.Dir(b)
)

func GetAbsolutePath(relativePath string) string {
	// basePath == the directory of this file - so we gotta go up one

	if relativePath[0] == '/' {
		return relativePath
	}

	return path.Join(basePath, "..", relativePath)
}

func SplitString(s string, r rune) []string {
	splitFn := func(c rune) bool {
		return c == r
	}

	return strings.FieldsFunc(s, splitFn)
}
