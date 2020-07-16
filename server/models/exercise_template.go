package models

import "github.com/lib/pq"

// ExerciseTemplate model
type ExerciseTemplate struct {
	Model
	ExerciseDictionaries []*ExerciseDictionary `json:"exercise_dictionaries" gorm:"many2many:resolved_exercise_dictionaries;"`
	CircuitID            *int                  `json:"circuit_id"`
	CircuitRounds        int                   `json:"circuit_rounds"`
	Data                 ExerciseTemplateData  `json:"data"`
}

func (ExerciseTemplate) TableName() string {
	return "exercise_templates"
}

// ExerciseData model ExerciseTemplateDataFields
type ExerciseTemplateData struct {
	HiddenModel

	IsSetsFieldEnabled     bool `json:"is_sets_field_enabled"`
	IsRepsFieldEnabled     bool `json:"is_reps_field_enabled"`
	IsWeightFieldEnabled   bool `json:"is_weight_field_enabled"`
	IsTimeFieldEnabled     bool `json:"is_time_field_enabled"`
	IsDistanceFieldEnabled bool `json:"is_distance_field_enabled"`

	Sets     int             `json:"sets"`
	Reps     pq.Int64Array   `json:"reps"`
	Weight   pq.Float64Array `json:"weight"`
	Time     pq.Int64Array   `json:"time"`
	Distance pq.Float64Array `json:"distance"`
	Calories pq.Int64Array   `json:"calories"`
}
