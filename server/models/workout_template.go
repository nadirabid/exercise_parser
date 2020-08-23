package models

// WorkoutTemplate model
type WorkoutTemplate struct {
	Model
	IsNotTemplate     bool               `json:"is_not_template"`
	UserID            uint               `json:"user_id" gorm:"type:int REFERENCES users(id) ON DELETE CASCADE"`
	Name              string             `json:"name"`
	SecondsElapsed    uint               `json:"seconds_elapsed"`
	ExerciseTemplates []ExerciseTemplate `json:"exercise_templates"`
}

func (WorkoutTemplate) TableName() string {
	return "workout_templates"
}
