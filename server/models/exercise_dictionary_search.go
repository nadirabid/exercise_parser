package models

import (
	"math"
	"sort"
	"strings"

	"github.com/jinzhu/gorm"
	"github.com/spf13/viper"
)

// ExerciseRelatedNameSearchResult holds the result values w/ rank info
type ExerciseRelatedNameSearchResult struct {
	ExerciseRelatedName
	ExerciseDictionaryName string  `json:"-"`
	Rank                   float32 `json:"rank"`
}

// ExerciseDictionarySearchResult holds search results based on matched ExerciseRelatedNames
type ExerciseDictionarySearchResult struct {
	ExerciseDictionaryID   uint                              `json:"exercise_dictionary_id"`
	ExerciseDictionaryName string                            `json:"exercise_dictionary_name"`
	Rank                   float32                           `json:"rank"`
	Related                []ExerciseRelatedNameSearchResult `json:"related"`
}

func SearchExerciseDictionaryWithRank(viper *viper.Viper, db *gorm.DB, name string, rank float32) ([]*ExerciseDictionarySearchResult, error) {
	results, err := SearchExerciseDictionary(viper, db, name)
	if err != nil {
		return results, err
	}

	filtered := []*ExerciseDictionarySearchResult{}

	for _, r := range results {
		if r.Rank > rank {
			filtered = append(filtered, r)
		}
	}

	return filtered, nil
}

// SearchExerciseDictionary will search for ExcerciseDictionary entity from the provided exercise name
func SearchExerciseDictionary(viper *viper.Viper, db *gorm.DB, name string) ([]*ExerciseDictionarySearchResult, error) {
	searchTerms := strings.Join(strings.Split(name, " "), " & ") + ":*"

	// TODO: make grabbing the dictionary name optional
	q := `
		SELECT exercise_related_names.*, exercise_dictionaries.name as exercise_dictionary_name, ts_rank(related_tsv, keywords, 2) AS rank
		FROM exercise_dictionaries, exercise_related_names, to_tsquery(?) keywords
		WHERE related_tsv @@ keywords AND exercise_dictionaries.id = exercise_related_names.exercise_dictionary_id
		ORDER BY rank DESC
	`

	groupedByPrimary := make(map[uint][]*ExerciseRelatedNameSearchResult)

	rows, err := db.Raw(q, searchTerms).Rows()
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		res := &ExerciseRelatedNameSearchResult{}
		db.ScanRows(rows, res)

		if _, ok := groupedByPrimary[res.ExerciseDictionaryID]; !ok {
			groupedByPrimary[res.ExerciseDictionaryID] = []*ExerciseRelatedNameSearchResult{}
		}

		groupedByPrimary[res.ExerciseDictionaryID] = append(groupedByPrimary[res.ExerciseDictionaryID], res)
	}

	// sum up the ranks per exercise dictionary (since the search results included related names of a exercise dictionary)
	results := []*ExerciseDictionarySearchResult{}
	for k, v := range groupedByPrimary {
		res := &ExerciseDictionarySearchResult{}
		res.ExerciseDictionaryID = k
		res.ExerciseDictionaryName = v[0].ExerciseDictionaryName

		rank := float32(0)
		for _, r := range v {
			if r.Type != "model" && r.Type != viper.GetString("resources.dir.related_names") {
				// if its a related search term, then lets reweigh it so that its not the same as a direct match
				r.Rank = calculateWeightOfRelatedSearch(r.Rank)
			} else {
				r.Rank *= 1.2
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

// SearchExerciseDictionaryLite will search for ExcerciseDictionary entity from the provided exercise name and return the dictionary IDs
func SearchExerciseDictionaryLite(viper *viper.Viper, db *gorm.DB, name string) ([]uint, error) {
	searchTerms := strings.Join(strings.Split(name, " "), " & ") + ":*"

	// TODO: make grabbing the dictionary name optional
	q := `
		SELECT exercise_related_names.exercise_dictionary_id, exercise_related_names.type, ts_rank(related_tsv, keywords, 2) AS rank
		FROM exercise_dictionaries, exercise_related_names, to_tsquery(?) keywords
		WHERE related_tsv @@ keywords AND exercise_dictionaries.id = exercise_related_names.exercise_dictionary_id
		ORDER BY rank DESC
	`

	type SearchResult struct {
		ExerciseDictionaryID uint    `json:"exercise_dictionary_id"`
		Rank                 float32 `json:"rank"`
		Type                 string  `json:"type"`
	}

	groupedByPrimary := make(map[uint][]*SearchResult)

	rows, err := db.Raw(q, searchTerms).Rows()
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		res := &SearchResult{}
		db.ScanRows(rows, res)

		if _, ok := groupedByPrimary[res.ExerciseDictionaryID]; !ok {
			groupedByPrimary[res.ExerciseDictionaryID] = []*SearchResult{}
		}

		groupedByPrimary[res.ExerciseDictionaryID] = append(groupedByPrimary[res.ExerciseDictionaryID], res)
	}

	// sum up the ranks per exercise dictionary (since the search results included related names of a exercise dictionary)
	results := []*SearchResult{}
	for k, v := range groupedByPrimary {
		res := &SearchResult{}
		res.ExerciseDictionaryID = k

		rank := float32(0)
		for _, r := range v {
			if r.Type != "model" && r.Type != viper.GetString("resources.dir.related_names") {
				// if its a related search term, then lets reweigh it so that its not the same as a direct match
				r.Rank = calculateWeightOfRelatedSearch(r.Rank)
			} else {
				r.Rank *= 1.2
			}

			rank += r.Rank
		}

		res.Rank = rank

		results = append(results, res)
	}

	// sort in descending order
	sort.Slice(results, func(i, j int) bool {
		if results[i].Rank < results[j].Rank {
			return false
		}

		return true
	})

	ids := make([]uint, len(results))

	for i := 0; i < len(results); i++ {
		ids[i] = results[i].ExerciseDictionaryID
	}

	return ids, nil
}

// https://www.wolframalpha.com/input/?i=(1%2F10000)e%5E(80*x+-+0.5),+x+from+0+to+0.1
func calculateWeightOfRelatedSearch(x float32) float32 {
	exp := float64(80)*float64(x) - float64(0.6)
	val := (float64(1.0) / float64(10000)) * math.Exp(exp)

	return float32(math.Min(val, 0.1))
}
