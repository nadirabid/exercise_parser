package models

import (
	"fmt"
	"math"
	"sort"
	"strings"

	"github.com/jinzhu/gorm"
)

// ExerciseRelatedNameSearchResult holds the result values w/ rank info
type ExerciseRelatedNameSearchResult struct {
	ExerciseRelatedName
	Rank float32
}

// ExerciseDictionarySearchResult holds search results based on matched ExerciseRelatedNames
type ExerciseDictionarySearchResult struct {
	Primary string                            `json:"primary"`
	Rank    float32                           `json:"rank"`
	Related []ExerciseRelatedNameSearchResult `json:"related"`
}

// SearchExerciseDictionary will search for ExcerciseDictionary entity from the provided exercise name
func SearchExerciseDictionary(db *gorm.DB, name string) ([]*ExerciseDictionarySearchResult, error) {
	searchTerms := strings.Join(strings.Split(name, " "), " & ")

	q := `
		SELECT *, ts_rank(related_tsv, keywords, 2) AS rank
		FROM exercise_related_names, to_tsquery(?) keywords
		WHERE related_tsv @@ keywords
		ORDER BY rank DESC
	`

	groupedByPrimary := make(map[string][]*ExerciseRelatedNameSearchResult)

	rows, err := db.Raw(q, searchTerms).Rows()
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		res := &ExerciseRelatedNameSearchResult{}
		db.ScanRows(rows, res)

		if _, ok := groupedByPrimary[res.Primary]; !ok {
			groupedByPrimary[res.Primary] = []*ExerciseRelatedNameSearchResult{}
		}

		groupedByPrimary[res.Primary] = append(groupedByPrimary[res.Primary], res)
	}

	results := []*ExerciseDictionarySearchResult{}
	for k, v := range groupedByPrimary {
		res := &ExerciseDictionarySearchResult{}
		res.Primary = k

		rank := float32(0)
		for _, r := range v {
			if r.Type != "" {
				fmt.Println(r.Type)
				r.Rank = calculateWeightOfRelatedSearch(r.Rank)
			}

			rank += r.Rank

			res.Related = append(res.Related, *r)
		}

		res.Rank = rank

		sort.Slice(res.Related, func(i, j int) bool {
			if res.Related[i].Rank < res.Related[j].Rank {
				return false
			}

			return true
		})

		results = append(results, res)
	}

	// sort in descending order
	sort.Slice(results, func(i, j int) bool {
		if results[i].Rank < results[j].Rank {
			return false
		}

		return true
	})

	return results, nil
}

// https://www.wolframalpha.com/input/?i=(1%2F10000)e%5E(80*x+-+0.5),+x+from+0+to+0.1
func calculateWeightOfRelatedSearch(x float32) float32 {
	exp := float64(80)*float64(x) - float64(0.5)
	val := (float64(1.0) / float64(10000)) * math.Exp(exp)

	return float32(math.Min(val, 0.1))
}
