package cmd

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

func configureViperFromCmd(cmd *cobra.Command) (*viper.Viper, error) {
	confFile, err := cmd.Flags().GetString("conf")
	if err != nil {
		return nil, err
	}

	v := viper.New()
	v.SetConfigType("toml")
	v.SetConfigFile(fmt.Sprintf("conf/%s.toml", confFile))

	if err := v.ReadInConfig(); err != nil {
		return nil, err
	}

	return v, nil
}

func pathToFileURL(path string) string {
	if !filepath.IsAbs(path) {
		var err error
		path, err = filepath.Abs(path)
		if err != nil {
			return ""
		}
	}
	return fmt.Sprintf("file://%s", filepath.ToSlash(path))
}

func isDirectory(name string) (bool, error) {
	info, err := os.Stat(name)
	if err != nil {
		return false, err
	}

	return info.IsDir(), nil
}

func sanitizeRelatedName(s string) string {
	s = strings.ToLower(s)
	s = strings.Replace(s, "-", " ", -1)
	s = strings.Trim(s, " ")
	return s
}

func removeStopWords(s string, stopWords []string) string {
	result := []string{""}
	tokens := strings.Split(s, " ")

	for _, t := range tokens {
		isStopWord := false
		for _, w := range stopWords {
			if t == w {
				isStopWord = true
				break
			}
		}

		if !isStopWord {
			result = append(result, t)
		}
	}

	return strings.Join(result, " ")
}
