package models

import "github.com/lib/pq"

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
	Target                pq.StringArray `gorm:"type:varchar(250)[]"`
	Synergists            pq.StringArray `gorm:"type:varchar(250)[]"`
	Stabilizers           pq.StringArray `gorm:"type:varchar(250)[]"`
	DynamicStabilizers    pq.StringArray `gorm:"type:varchar(250)[]"`
	AntagonistStabilizers pq.StringArray `gorm:"type:varchar(250)[]"`
	ROMCriteria           pq.StringArray `gorm:"type:varchar(250)[]"`
	ExerciseTypeID        int            `json:"exercise_type_id"`
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
	Ankle          pq.StringArray `json:"ankle" gorm:"type:varchar(250)[]"`
	Elbow          pq.StringArray `json:"elbow" gorm:"type:varchar(250)[]"`
	Finger         pq.StringArray `json:"finger" gorm:"type:varchar(250)[]"`
	Foot           pq.StringArray `json:"foot" gorm:"type:varchar(250)[]"`
	Forearms       pq.StringArray `json:"forearms" gorm:"type:varchar(250)[]"`
	Hip            pq.StringArray `json:"hip" gorm:"type:varchar(250)[]"`
	Scapula        pq.StringArray `json:"scapula" gorm:"type:varchar(250)[]"`
	Clavicle       pq.StringArray `json:"clavicle" gorm:"type:varchar(250)[]"`
	Shoulder       pq.StringArray `json:"shoulder" gorm:"type:varchar(250)[]"`
	ShoulderGirdle pq.StringArray `json:"shoulder_girdle" gorm:"type:varchar(250)[]"`
	Spine          pq.StringArray `json:"spine" gorm:"type:varchar(250)[]"`
	Thumb          pq.StringArray `json:"thumb" gorm:"type:varchar(250)[]"`
	Wrist          pq.StringArray `json:"wrist" gorm:"type:varchar(250)[]"`
	Knee           pq.StringArray `json:"knee" gorm:"type:varchar(250)[]"`
	ArticulationID int            `json:"articulation_id"`
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
