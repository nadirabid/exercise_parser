package models

// WorkoutTemplate model
type WorkoutTemplate struct {
	Model
	UserID            uint               `json:"user_id" gorm:"type:int REFERENCES users(id) ON DELETE CASCADE"`
	Name              string             `json:"name"`
	ExerciseTemplates []ExerciseTemplate `json:"exercises"`
}

func (WorkoutTemplate) TableName() string {
	return "workout_templates"
}
