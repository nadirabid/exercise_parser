package models

// Following model
type UserFollow struct {
	Model
	user   User
	follow User
}

func (UserFollow) TableName() string {
	return "user_follow"
}
