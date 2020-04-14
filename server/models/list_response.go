package models

// ListResponse is generic struct for returning lists
type ListResponse struct {
	Page    int         `json:"page"` // starts w/ zero
	Pages   int         `json:"pages"`
	Size    int         `json:"size"`
	Results interface{} `json:"results"`
}
