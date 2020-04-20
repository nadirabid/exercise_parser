package models

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"strings"
	"testing"

	"github.com/spf13/viper"
	"github.com/stretchr/testify/assert"
)

// NOTE: assume the database has been seeded via: `./exercise_parser dict seed`

type testData struct {
	Search   string
	Expected string
}

func loadTestDatums() ([]testData, error) {
	// TODO: read test data file dir location from viper/conf file
	const testDataFile = "../resources/test_data/exercise_classification.csv"
	file, err := os.Open(testDataFile)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	reader := bufio.NewReader(file)

	datums := []testData{}

	for {
		next, err := reader.ReadString('\n')
		if err == io.EOF {
			break
		} else if err != nil {
			return nil, err
		}

		next = strings.Trim(next, "\n")
		fields := strings.Split(next, ",")

		d := testData{}
		d.Search = strings.Trim(fields[0], " ")
		d.Expected = strings.Trim(fields[1], " ")

		datums = append(datums, d)
	}

	return datums, nil
}

func TestSearchTestData(t *testing.T) {
	v := viper.New()
	v.SetConfigType("toml")
	v.SetConfigFile(fmt.Sprintf("../conf/%s.toml", "dev"))

	if err := v.ReadInConfig(); err != nil {
		t.Fatal(err.Error())
	}

	db, err := NewDatabase(v)

	if err != nil {
		t.Fatal(err.Error())
	}

	testDatums, err := loadTestDatums()
	if err != nil {
		t.Fatal(err.Error())
	}

	for _, d := range testDatums {
		t.Run(fmt.Sprintf("%s should resolve to %s", d.Search, d.Expected), func(t *testing.T) {
			results, err := SearchExerciseDictionary(db, d.Search)
			if err != nil {
				t.Error(err.Error())
			}

			if len(results) == 0 {
				t.Errorf("search for %s yielded nothing", d.Search)
			}

			highestRanked := results[0]

			e := &ExerciseDictionary{}
			if err := db.Where("id = ?", highestRanked.ExerciseDictionaryID).First(e).Error; err != nil {
				t.Fatal(err.Error())
			}

			assert.Equal(t, d.Expected, e.Name)
		})
	}
}
