package server

import (
	"exercise_parser/models"
	"math"

	"github.com/jinzhu/gorm"
)

type Param struct {
	DB    *gorm.DB
	Page  int
	Limit int
}

func getListResponse(p *Param, result interface{}) (*models.ListResponse, error) {
	db := p.DB

	if p.Page < 0 {
		p.Page = 0
	}

	if p.Limit == 0 {
		p.Limit = 10
	}

	list := models.ListResponse{}
	count := 0
	offset := p.Page * p.Limit

	err := db.Limit(p.Limit).Offset(offset).Find(result).Error
	if err != nil {
		return nil, err
	}

	list.Size = p.Limit
	list.Results = result
	list.Page = p.Page
	list.Pages = int(math.Ceil(float64(count) / float64(p.Limit)))

	return &list, nil
}
