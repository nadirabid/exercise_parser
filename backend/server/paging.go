package server

import (
	"exercise_parser/models"
	"math"

	"github.com/jinzhu/gorm"
)

func paging(db *gorm.DB, page int, size int, result interface{}) (*models.ListResponse, error) {
	if page < 0 {
		page = 0
	}

	list := models.ListResponse{}
	count := 0
	offset := page * size

	// err := db.Count(&count).Error
	// if err != nil {
	// 	return nil, err
	// }

	err := db.Limit(size).Offset(offset).Find(result).Error
	if err != nil {
		return nil, err
	}

	list.Size = size
	list.Results = result
	list.Page = page
	list.Pages = int(math.Ceil(float64(count) / float64(size)))

	return &list, nil
}
