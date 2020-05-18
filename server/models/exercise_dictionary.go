package models

import (
	"fmt"

	"github.com/jinzhu/gorm"
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
	ExerciseDictionaryID uint   `json:"exercise_dictionary_id" gorm:"type:int REFERENCES exercise_dictionaries(id) ON DELETE CASCADE"`
}

func (Classification) TableName() string {
	return "classifications"
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
	DynamicArticulation   pq.StringArray `json:"dynamic_articulation" gorm:"type:varchar(250)[]"`
	StaticArticulation    pq.StringArray `json:"static_articulation" gorm:"type:varchar(250)[]"`
	ExerciseDictionaryID  uint           `json:"exercise_dictionary_id" gorm:"type:int REFERENCES exercise_dictionaries(id) ON DELETE CASCADE"`
}

func (Muscles) TableName() string {
	return "muscles"
}

// Articulation is Plyometric as far as I can tell
type Articulation struct {
	HiddenModel
	Dynamic              Joints `json:"dynamic"`
	Static               Joints `json:"static"`
	ExerciseDictionaryID uint   `json:"exercise_dictionary_id" gorm:"type:int REFERENCES exercise_dictionaries(id) ON DELETE CASCADE"`
}

func (Articulation) TableName() string {
	return "articulations"
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

func (Joints) TableName() string {
	return "joints"
}

// ExerciseRelatedName is a mapping of all the related names given a
type ExerciseRelatedName struct {
	ID                   uint   `json:"id" gorm:"primary_key"`
	ExerciseDictionaryID uint   `json:"exercise_dictionary_id" gorm:"type:int REFERENCES exercise_dictionaries(id) ON DELETE SET NULL"`
	Related              string `json:"related" gorm:"unique"`
	RelatedTSV           string `json:"-" gorm:"type:tsvector"`
	Type                 string `json:"type"`
	Ignored              bool   `json:"ignored"`
}

func (ExerciseRelatedName) TableName() string {
	return "exercise_related_names"
}

func (r *ExerciseRelatedName) UpdateTSV(db *gorm.DB) error {
	setTSV := `
		UPDATE exercise_related_names
		SET related_tsv=to_tsvector('english', coalesce(exercise_related_names.related, ''))
		WHERE id = ?
	`

	if err := db.Exec(setTSV, r.ID).Error; err != nil {
		return fmt.Errorf("unable to set tsvector: %s", err.Error())
	}

	return nil
}

// ExerciseDictionary is a single exercise type
type ExerciseDictionary struct {
	Model
	URL            string         `json:"url"`
	Name           string         `json:"name" gorm:"unique"`
	Classification Classification `json:"classification"`
	Muscles        Muscles        `json:"muscles"`
	Articulation   Articulation   `json:"articulation"`
	TSV            string         `json:"-" gorm:"type:tsvector"`
}

func (ExerciseDictionary) TableName() string {
	return "exercise_dictionaries"
}
