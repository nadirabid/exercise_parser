package models

// UserSubscription model
type UserSubscription struct {
	Model
	SubscriberID   uint `json:"subscriber_id"`
	SubscribedToID uint `json:"subscribed_to_id"`
}

func (UserSubscription) TableName() string {
	return "user_subscriptions"
}
