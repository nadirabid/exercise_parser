package models

import (
	"exercise_parser/parser"
	"exercise_parser/utils"
	"fmt"
	"strconv"
	"strings"
	"time"
)

// Workout model
type Workout struct {
	Model
	UserID         uint       `json:"user_id" gorm:"type:int REFERENCES users(id) ON DELETE CASCADE"`
	Name           string     `json:"name"`
	Date           time.Time  `json:"date"`
	Location       *Location  `json:"location"`
	SecondsElapsed uint       `json:"seconds_elapsed"`
	Exercises      []Exercise `json:"exercises"`
}

func (Workout) TableName() string {
	return "workouts"
}

// HasExercise returns true if Exercise exists with id, otherwise false
func (w *Workout) HasExercise(id uint) bool {
	for _, e := range w.Exercises {
		if e.ID == id {
			return true
		}
	}

	return false
}

type Location struct {
	Model
	Latitude  float64 `json:"latitude" gorm:"not null"`
	Longitude float64 `json:"longitude" gorm:"not null"`
	WorkoutID uint    `json:"workout_id" gorm:"type:int REFERENCES workouts(id) ON DELETE CASCADE"`
}

func (Location) TableName() string {
	return "locations"
}

// Exercise model
type Exercise struct {
	Model
	Raw                  string            `json:"raw"`
	Type                 string            `json:"type"`
	ResolutionType       string            `json:"resolution_type"`
	Name                 string            `json:"name"`
	ExerciseDictionaryID *uint             `json:"exercise_dictionary_id" gorm:"type:int REFERENCES exercise_dictionaries(id) ON DELETE SET NULL"`
	ExerciseData         ExerciseData      `json:"data"`
	WeightedExercise     *WeightedExercise `json:"weighted_exercise"`
	DistanceExercise     *DistanceExercise `json:"distance_exercise"`
	WorkoutID            uint              `json:"workout_id" gorm:"type:int REFERENCES workouts(id) ON DELETE CASCADE"`
}

func (Exercise) TableName() string {
	return "exercises"
}

// Resolve will take the Raw exercise string and parse out the various fields
func (e *Exercise) Resolve() error {
	res, err := parser.Get().Resolve(e.Raw)
	if err != nil {
		return err
	}

	e.Type = res.Type
	e.Name = res.Captures["Exercise"]

	sets, err := evalSets(res.Captures)
	if err != nil {
		return err
	}

	reps, err := evalReps(res.Captures)
	if err != nil {
		return err
	}

	weight, err := evalWeight(res.Captures)
	if err != nil {
		return err
	}

	distance, err := evalDistance(res.Captures)
	if err != nil {
		return err
	}

	time, err := evalTime(res.Captures)
	if err != nil {
		return err
	}

	e.ExerciseData.Sets = sets
	e.ExerciseData.Reps = reps
	e.ExerciseData.Weight = weight
	e.ExerciseData.Distance = distance
	e.ExerciseData.Time = time

	e.ResolutionType = "auto"

	return nil
}

// WeightedExercise model
type WeightedExercise struct {
	HiddenModel
	Sets       int     `json:"sets"`
	Reps       int     `json:"reps"`
	Weight     float32 `json:"weight"`
	ExerciseID uint    `json:"exercise_id" gorm:"type:int REFERENCES exercises(id) ON DELETE CASCADE"`
}

func (WeightedExercise) TableName() string {
	return "weighted_exercises"
}

// DistanceExercise model
type DistanceExercise struct {
	HiddenModel
	Time       uint    `json:"time"`
	Distance   float32 `json:"distance"`
	ExerciseID uint    `json:"exercise_id" gorm:"type:int REFERENCES exercises(id) ON DELETE CASCADE"`
}

func (DistanceExercise) TableName() string {
	return "distance_exercises"
}

type ExerciseData struct {
	HiddenModel
	Sets       int     `json:"sets"`
	Reps       int     `json:"reps"`
	Weight     float32 `json:"weight"`
	Time       uint    `json:"time"`
	Distance   float32 `json:"distance"`
	ExerciseID uint    `json:"exercise_id" gorm:"type:int REFERENCES exercises(id) ON DELETE CASCADE"`
}

func (ExerciseData) TableName() string {
	return "exercise_data"
}

// returns 1 if not specified
func evalSets(captures map[string]string) (int, error) {
	setStr, ok := captures["Sets"]
	if !ok {
		return 1, nil
	}

	sets, err := strconv.Atoi(setStr)
	if err != nil {
		return 0, nil
	}

	return sets, nil
}

// return 0 if not specified
func evalRest(captures map[string]string) (int, error) {
	restPeriodStr, ok := captures["RestPeriod"]
	if !ok {
		return 0, nil
	}

	restPeriodUnits := utils.GetStringOrDefault(captures["RestPeriodUnits"], "minutes")

	if strings.Contains(restPeriodStr, "-") {
		restPeriodTokens := strings.Split(restPeriodStr, "-")
		if len(restPeriodTokens) != 2 {
			return 0, fmt.Errorf("RestPeriod contains -, but doesn't have two rest period numbers. Eg of expected: 2-3")
		}

		restPeriod1, err := strconv.Atoi(restPeriodTokens[0])
		restPeriod2, err := strconv.Atoi(restPeriodTokens[1])
		if err != nil {
			return 0, err
		}

		restPeriod := utils.MaxInt(restPeriod1, restPeriod2)

		standardizedRestPeriod, err := parser.UnitStandardize(restPeriodUnits, float32(restPeriod))
		if err != nil {
			return 0, err
		}

		return int(standardizedRestPeriod), nil
	}

	restPeriod, err := strconv.Atoi(restPeriodStr)
	if err != nil {
		return 0, err
	}

	standardizedRestPeriod, err := parser.UnitStandardize(restPeriodUnits, float32(restPeriod))
	if err != nil {
		return 0, err
	}

	return int(standardizedRestPeriod), nil
}

// returns 1 if not specified
func evalReps(captures map[string]string) (int, error) {
	repStr, ok := captures["Reps"]
	if !ok {
		return 1, nil
	}

	if strings.Contains(repStr, "-") {
		repTokens := strings.Split(repStr, "-")
		if len(repTokens) != 2 {
			return 0, fmt.Errorf("Reps contains -, but doesn't have two rep numbers. Eg of expected: 10-12")
		}

		reps1, err := strconv.Atoi(repTokens[0])
		reps2, err := strconv.Atoi(repTokens[1])

		if err != nil {
			return 0, err
		}

		return utils.MaxInt(reps1, reps2), nil
	}

	reps, err := strconv.Atoi(repStr)
	if err != nil {
		return 0, err
	}
	return reps, nil
}

// returns 0 if not specified
func evalWeight(captures map[string]string) (float32, error) {
	weightStr, ok := captures["Weight"]
	if !ok {
		return 0, nil
	}

	unit := utils.GetStringOrDefault(captures["WeightUnits"], "pounds")

	weight, err := strconv.ParseFloat(weightStr, 32)
	if err != nil {
		return 0, err
	}

	standardized, err := parser.UnitStandardize(unit, float32(weight))
	if err != nil {
		return 0, err
	}

	return standardized, nil
}

// returns 0 if not specified
func evalTime(captures map[string]string) (uint, error) {
	timeStr, ok := captures["Time"]
	if !ok {
		return 0, nil
	}

	timeUnit := utils.GetStringOrDefault(captures["TimeUnits"], "minutes")

	time, err := strconv.ParseFloat(timeStr, 32)
	if err != nil {
		return 0, err
	}

	standardizedTime, err := parser.UnitStandardize(timeUnit, float32(time))
	if err != nil {
		return 0, err
	}

	return uint(standardizedTime), nil
}

// returns 0 if not specified
func evalDistance(captures map[string]string) (float32, error) {
	if captures["Distance"] == "" {
		return 0, nil
	}

	unit := utils.GetStringOrDefault(captures["DistanceUnits"], "miles")

	distance, err := strconv.ParseFloat(captures["Distance"], 32)
	if err != nil {
		return 0, err
	}

	standardizedDist, err := parser.UnitStandardize(unit, float32(distance))
	if err != nil {
		return 0, err
	}

	return standardizedDist, nil
}
