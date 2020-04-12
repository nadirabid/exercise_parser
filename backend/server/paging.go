package server

import (
	"exercise_parser/models"
	"math"

	"github.com/jinzhu/gorm"
)

type Param struct {
	DB      *gorm.DB
	Page    int
	Limit   int
	OrderBy []string
	ShowSQL bool
}

func Paging(p *Param, result interface{}) (*models.ListResponse, error) {
	db := p.DB

	if p.ShowSQL {
		db = db.Debug()
	}

	if p.Page < 0 {
		p.Page = 0
	}

	if p.Limit == 0 {
		p.Limit = 10
	}

	if len(p.OrderBy) > 0 {
		for _, o := range p.OrderBy {
			db = db.Order(o)
		}
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
