package parser

import (
	"bufio"
	"exercise_parser/utils"
	"os"
	"strings"

	"github.com/spf13/viper"
)

type stopPhrases struct {
	phrases []string
}

func newStopPhrases(v *viper.Viper) *stopPhrases {
	filePath := utils.GetAbsolutePath(v.GetString("parser.stop_phrases"))
	file, err := os.Open(filePath)

	if err != nil {
		panic(err.Error())
	}
	defer file.Close()

	phrases := []string{}

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()

		if err := scanner.Err(); err != nil {
			panic(err.Error())
		}

		phrases = append(phrases, line)
	}

	return &stopPhrases{
		phrases: phrases,
	}
}

func (p *stopPhrases) removeStopPhrases(e string) string {
	for _, p := range p.phrases {
		e = strings.ReplaceAll(e, p, "")
	}

	return e
}
