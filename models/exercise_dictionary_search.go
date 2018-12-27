package models

import (
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
			if r.Type == "resources/related_searches_goog" {
				r.Rank *= 0.1
			} else if r.Type == "resources/related_searches_bing" {
				r.Rank *= 0.1
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
