package models

const (
	TargetMuscle               = "TargetMuscle"
	SynergistMuscle            = "SynergistMuscle"
	StabilizerMuscle           = "StabilizerMuscle"
	DynamicStabilizerMuscle    = "DynamicStabilizerMuscle"
	AntagonistStabilizerMuscle = "AntagonistStabilizerMuscle"
	DynamicArticulationMuscle  = "DynamicArticulation"
	StaticArticulationMuscle   = "StaticArticulation"
)

// TODO: should metric be associated with workoutID or a time range?
type Metric struct {
	Model
	Muscles   []MetricMuscle `json:"muscles"`
	TopLevel  MetricTopLevel `json:"top_level"`
	WorkoutID uint           `json:"-" gorm:"type:int REFERENCES workouts(id) ON DELETE CASCADE"`
}

func (Metric) TableName() string {
	return "metrics"
}

type MetricTopLevel struct {
	HiddenModel
	Distance       float32 `json:"distance"`
	Sets           int     `json:"sets"`
	Reps           int     `json:"reps"`
	SecondsElapsed uint    `json:"seconds_elapsed"`
	Calories       int     `json:"calories"`
	MetricID       uint    `json:"metric_id" gorm:"type:int REFERENCES metrics(id) ON DELETE CASCADE"`
}

func (MetricTopLevel) TableName() string {
	return "metrics_top_level"
}

type MetricMuscle struct {
	HiddenModel
	Name     string `json:"name"`
	Usage    string `json:"usage"`
	Reps     int    `json:"reps"`
	MetricID uint   `json:"metric_id" gorm:"type:int REFERENCES metrics(id) ON DELETE CASCADE"`
}

func (MetricMuscle) TableName() string {
	return "metrics_muscle"
}
