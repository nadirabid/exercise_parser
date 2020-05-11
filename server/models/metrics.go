package models

type MuscleStat struct {
	Muscle string `json:"muscle"`
	Reps   int    `json:"reps"`
}

type MuscleMetric struct {
	TargetMuscles               []MuscleStat `json:"target_muscles"`
	SynergistMuscles            []MuscleStat `json:"synergist_muscles"`
	StabilizerMuscles           []MuscleStat `json:"stabilizer_muscles"`
	DynamicStabilizerMuscles    []MuscleStat `json:"dynamic_stabilizer_muscles"`
	AntagonistStabilizerMuscles []MuscleStat `json:"antagonist_stabilizer_muscles"`
}

type TopLevelMetric struct {
	Distance       float32 `json:"distance"`
	Sets           int     `json:"sets"`
	Reps           int     `json:"reps"`
	SecondsElapsed uint    `json:"seconds_elapsed"`
}

type Metric struct {
	Muscle   MuscleMetric   `json:"muscle"`
	TopLevel TopLevelMetric `json:"top_level"`
}
