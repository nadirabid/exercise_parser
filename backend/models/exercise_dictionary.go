package models

import (
	"github.com/lib/pq"
)

// Classification of exercise
type Classification struct {
	HiddenModel
	Utility              string `json:"utility"`
	Mechanics            string `json:"mechanics"`
	Force                string `json:"force"`
	Intensity            string `json:"intensity"`
	Function             string `json:"function"`
	Bearing              string `json:"bearing"`
	Impact               string `json:"impact"`
	ExerciseDictionaryID uint   `json:"exercise_type_id" gorm:"type:int REFERENCES exercise_dictionaries(id) ON DELETE CASCADE"`
}

// Muscles are the areas that a given exercise affects
type Muscles struct {
	HiddenModel
	Target                pq.StringArray `json:"target" gorm:"type:varchar(250)[]"`
	Synergists            pq.StringArray `json:"synergists" gorm:"type:varchar(250)[]"`
	Stabilizers           pq.StringArray `json:"stabilizers" gorm:"type:varchar(250)[]"`
	DynamicStabilizers    pq.StringArray `json:"dynamic_stabilizers" gorm:"type:varchar(250)[]"`
	AntagonistStabilizers pq.StringArray `json:"antagonist_stabilizers" gorm:"type:varchar(250)[]"`
	ROMCriteria           pq.StringArray `json:"rom_criteria" gorm:"type:varchar(250)[]"`
	ExerciseDictionaryID  uint           `json:"exercise_type_id" gorm:"type:int REFERENCES exercise_dictionaries(id) ON DELETE CASCADE"`
}

// Articulation is Plyometric as far as I can tell
type Articulation struct {
	HiddenModel
	Dynamic              Joints `json:"dynamic"`
	Static               Joints `json:"static"`
	ExerciseDictionaryID uint   `json:"exercise_type_id" gorm:"type:int REFERENCES exercise_dictionaries(id) ON DELETE CASCADE"`
}

// Joints for dynamic/static articulation
type Joints struct {
	HiddenModel
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
	ArticulationID int            `json:"articulation_id" gorm:"type:int REFERENCES articulations(id) ON DELETE CASCADE"`
}

// ExerciseRelatedName is a mapping of all the related names given a
type ExerciseRelatedName struct {
	ID                   uint   `json:"-" gorm:"primary_key"`
	ExerciseDictionaryID uint   `json:"exercise_dictionary_id" gorm:"type:int REFERENCES exercise_dictionaries(id) ON DELETE SET NULL"`
	Related              string `json:"related" gorm:"primary_key"`
	RelatedTSV           string `json:"-" gorm:"type:tsvector"`
	Type                 string `json:"-"`
}

// ExerciseDictionary is a single exercise type
type ExerciseDictionary struct {
	HiddenModel
	URL            string         `json:"url"`
	Name           string         `json:"name" gorm:"unique"`
	Classification Classification `json:"classification"`
	Muscles        Muscles        `json:"muscles"`
	Articulation   Articulation   `json:"articulation"`
	TSV            string         `json:"-" gorm:"type:tsvector"`
}
