package models

type Metric struct {
	Muscle    MuscleMetric   `json:"muscle"`
	TopLevel  TopLevelMetric `json:"top_level"`
	WorkoutID uint           `json:"workout_id" gorm:"type:int REFERENCES workouts(id) ON DELETE CASCADE"`
}

func (Metric) TableName() string {
	return "metrics"
}

type TopLevelMetric struct {
	HiddenModel
	Distance       float32 `json:"distance"`
	Sets           int     `json:"sets"`
	Reps           int     `json:"reps"`
	SecondsElapsed uint    `json:"seconds_elapsed"`
	MetricID       uint    `json:"metric_id" gorm:"type:int REFERENCES metrics(id) ON DELETE CASCADE"`
}

func (TopLevelMetric) TableName() string {
	return "top_level_metrics"
}

type MuscleMetric struct {
	HiddenModel
	TargetMuscles               []MuscleStat `json:"target_muscles"`
	SynergistMuscles            []MuscleStat `json:"synergist_muscles"`
	StabilizerMuscles           []MuscleStat `json:"stabilizer_muscles"`
	DynamicStabilizerMuscles    []MuscleStat `json:"dynamic_stabilizer_muscles"`
	AntagonistStabilizerMuscles []MuscleStat `json:"antagonist_stabilizer_muscles"`
	MetricID                    uint         `json:"metric_id" gorm:"type:int REFERENCES metrics(id) ON DELETE CASCADE"`
}

func (MuscleMetric) TableName() string {
	return "muscle_metrics"
}

type MuscleStat struct {
	HiddenModel
	Muscle         string `json:"muscle"`
	Reps           int    `json:"reps"`
	MuscleMetricID uint   `json:"muscle_metric_id" gorm:"type:int REFERENCES muscle_metrics(id) ON DELETE CASCADE"`
}

func (MuscleStat) TableName() string {
	return "muscle_stats"
}
