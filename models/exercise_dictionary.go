package models

import "github.com/lib/pq"

// Classification of exercise
type Classification struct {
	Model
	Utility              string `json:"utility"`
	Mechanics            string `json:"mechanics"`
	Force                string `json:"force"`
	Intensity            string `json:"intensity"`
	Function             string `json:"function"`
	Bearing              string `json:"bearing"`
	Impact               string `json:"impact"`
	ExerciseDictionaryID int    `json:"exercise_type_id"`
}

// Muscles are the areas that a given exercise affects
type Muscles struct {
	Model
	Target                pq.StringArray `json:"target" gorm:"type:varchar(250)[]"`
	Synergists            pq.StringArray `json:"synergists" gorm:"type:varchar(250)[]"`
	Stabilizers           pq.StringArray `json:"stabilizers" gorm:"type:varchar(250)[]"`
	DynamicStabilizers    pq.StringArray `json:"dynamic_stabilizers" gorm:"type:varchar(250)[]"`
	AntagonistStabilizers pq.StringArray `json:"antagonist_stabilizers" gorm:"type:varchar(250)[]"`
	ROMCriteria           pq.StringArray `json:"rom_criteria" gorm:"type:varchar(250)[]"`
	ExerciseDictionaryID  int            `json:"exercise_type_id"`
}

// Articulation is Plyometric as far as I can tell
type Articulation struct {
	Model
	Dynamic              Joints `json:"dynamic"`
	Static               Joints `json:"static"`
	ExerciseDictionaryID int    `json:"exercise_type_id"`
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

// ExerciseDictionary is a single exercise type
type ExerciseDictionary struct {
	Model
	URL            string         `json:"url"`
	Name           string         `json:"name; unique"`
	Classification Classification `json:"classification"`
	Muscles        Muscles        `json:"muscles"`
	Articulation   Articulation   `json:"articulation"`
	TSV            string         `json:"-" gorm:"type:tsvector"`
}
