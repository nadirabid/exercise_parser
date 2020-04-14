package parser

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
)

type lemma struct {
	mapping map[string][]string
}

func newLemma() *lemma {
	return &lemma{
		mapping: make(map[string][]string),
	}
}

func (l *lemma) get(s string) string {
	if v, ok := l.mapping[s]; ok {
		return v[0]
	}

	return s
}

func (l *lemma) readLemmas(dir string) error {
	files, err := ioutil.ReadDir(dir)
	if err != nil {
		return err
	}

	for _, f := range files {
		file, err := os.Open(filepath.Join(dir, f.Name()))
		if err != nil {
			return err
		}
		defer file.Close()

		scanner := bufio.NewScanner(file)
		for scanner.Scan() {
			line := scanner.Text()
			parts := strings.Split(strings.TrimSpace(line), "\t")

			if len(parts) == 2 {
				base := strings.ToLower(parts[0])
				form := strings.ToLower(parts[1])
				l.mapping[form] = append(l.mapping[form], base)
			} else {
				return fmt.Errorf("Line must be exactly two parts seperated by tab character: %s", line)
			}
		}

		if err := scanner.Err(); err != nil {
			return err
		}
	}

	return nil
}
