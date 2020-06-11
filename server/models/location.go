package models

type Location struct {
	Model
	Latitude   float64 `json:"latitude" gorm:"not null"`
	Longitude  float64 `json:"longitude" gorm:"not null"`
	ExerciseID *uint   `json:"exercise_id"`
	WorkoutID  uint    `json:"workout_id" gorm:"type:int REFERENCES workouts(id) ON DELETE CASCADE"` // TODO: remove??
}

func (Location) TableName() string {
	return "locations"
}
