package models

// Classification of exercise
type Classification struct {
	Model
	Utility        string
	Mechanics      string
	Force          string
	Intensity      string
	Function       string
	Bearing        string
	Impact         string
	ExerciseTypeID int `json:"exercise_type_id"`
}

// Muscles are the areas that a given exercise affects
type Muscles struct {
	Model
	Target                []string `gorm:"type:varchar(250)[]"`
	Synergists            []string `gorm:"type:varchar(250)[]"`
	Stabilizers           []string `gorm:"type:varchar(250)[]"`
	DynamicStabilizers    []string `gorm:"type:varchar(250)[]"`
	AntagonistStabilizers []string `gorm:"type:varchar(250)[]"`
	ROMCriteria           []string `gorm:"type:varchar(250)[]"`
	ExerciseTypeID        int      `json:"exercise_type_id"`
}

// Articulation is Plyometric as far as I can tell
type Articulation struct {
	Model
	Dynamic        Joints
	Static         Joints
	ExerciseTypeID int `json:"exercise_type_id"`
}

// Joints for dynamic/static articulation
type Joints struct {
	Model
	Ankle          []string `json:"ankle" gorm:"type:varchar(250)[]"`
	Elbow          []string `json:"elbow" gorm:"type:varchar(250)[]"`
	Finger         []string `json:"finger" gorm:"type:varchar(250)[]"`
	Foot           []string `json:"foot" gorm:"type:varchar(250)[]"`
	Forearms       []string `json:"forearms" gorm:"type:varchar(250)[]"`
	Hip            []string `json:"hip" gorm:"type:varchar(250)[]"`
	Scapula        []string `json:"scapula" gorm:"type:varchar(250)[]"`
	Clavicle       []string `json:"clavicle" gorm:"type:varchar(250)[]"`
	Shoulder       []string `json:"shoulder" gorm:"type:varchar(250)[]"`
	ShoulderGirdle []string `json:"shoulder_girdle" gorm:"type:varchar(250)[]"`
	Spine          []string `json:"spine" gorm:"type:varchar(250)[]"`
	Thumb          []string `json:"thumb" gorm:"type:varchar(250)[]"`
	Wrist          []string `json:"wrist" gorm:"type:varchar(250)[]"`
	Knee           []string `json:"knee" gorm:"type:varchar(250)[]"`
	ArticulationID int      `json:"articulation_id"`
}

// ExerciseType is a single exercise type
type ExerciseType struct {
	Model
	URL            string
	Name           string
	Classification Classification
	Muscles        Muscles
	Articulation   Articulation
}
