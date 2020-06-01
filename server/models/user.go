package models

import (
	"time"

	"github.com/lib/pq"
)

// User model
type User struct {
	Model
	GivenName      string             `json:"given_name"`
	FamilyName     string             `json:"family_name"`
	Email          string             `json:"email"`
	ExternalUserId string             `json:"external_user_id" gorm:"unique_index:ext_id; not null"` // this comes externally, in the case of apple - this is their stable id
	Subscriptions  []UserSubscription `json:"subscriptions"`
	ImagePath      string             `json:"-"`
	Roles          pq.StringArray     `json:"roles"`
	Birthdate      time.Time          `json:"birthdate"`
	Weight         float32            `json:"weight"`
	Height         float32            `json:"height"`
	IsMale         bool               `json:"is_male"`
}

// WrappedUser - this is for returning data through API with fields that don't necessarily
// exist in the database
type WrappedUser struct {
	User
	ImageExists bool `json:"image_exists"`
}

func (User) TableName() string {
	return "users"
}
