package models

// UserFollow model
type UserFollow struct {
	Model
	UserID   uint `json:"user_id"`
	FollowID uint `json:"follow_id"`
}

func (UserFollow) TableName() string {
	return "user_follows"
}
