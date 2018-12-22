package cmd

// use to serialize/deserialize related exericse name resources
type relatedTerms struct {
	Name    string
	Related []string
}

type bingAnswer struct {
	RelatedSearches struct {
		Value []struct {
			Text string `json:"text"`
		} `json:"value"`
	} `json:"relatedSearches"`
}
