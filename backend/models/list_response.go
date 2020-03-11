package models

// ListResponse is generic struct for returning lists
type ListResponse struct {
	Page    int         `json:"page"`
	Pages   int         `json:"pages"`
	Count   int         `json:"count"`
	Results interface{} `json:"results"`
}
