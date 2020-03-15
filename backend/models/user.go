package models

type User struct {
	Model
	GivenName      string `json:"given_name"`
	FamilyName     string `json:"family_name"`
	Email          string `json:"email"`
	ExternalUserId string `json:"external_user_id" gorm:"unique_index:ext_id; not null` // this comes externally, in the case of apple - this is their stable id
}
