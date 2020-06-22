package models

import (
	"exercise_parser/parser"
	"exercise_parser/utils"
	"fmt"
	"strconv"
	"strings"

	"github.com/jinzhu/gorm"
	"github.com/spf13/viper"
)

// Exercise model
type Exercise struct {
	Model
	Raw                  string                `json:"raw"`
	Type                 string                `json:"type"`            // using this for parser.ParseType - probably rename to Exercise.ParseType
	ResolutionType       string                `json:"resolution_type"` // using this to determine if exercise dictionaries were matched
	Name                 string                `json:"name"`
	ExerciseDictionaryID *uint                 `json:"exercise_dictionary_id" gorm:"type:int REFERENCES exercise_dictionaries(id) ON DELETE SET NULL"` // TODO - get rid of this?
	ExerciseData         ExerciseData          `json:"data"`
	WorkoutID            uint                  `json:"workout_id" gorm:"type:int REFERENCES workouts(id) ON DELETE CASCADE"`
	ExerciseDictionaries []*ExerciseDictionary `json:"exercise_dictionaries" gorm:"many2many:resolved_exercise_dictionaries;"`
	CorrectiveCode       int                   `json:"corrective_code"`
	CircuitID            *int                  `json:"circuit_id"`
	CircuitRounds        int                   `json:"circuit_rounds"`
	Locations            []Location            `json:"locations"`
}

func (Exercise) TableName() string {
	return "exercises"
}

const (
	AutoSingleResolutionType        = "auto.single"
	AutoCompoundResolutionType      = "auto.compound"
	AutoSpecialRestResolutionType   = "auto.special.rest" // this seems like a bady way of doing things (right now its for the ios client to distinguish this from rest of exericses to display it uniquely)
	AutoRunTracker                  = "auto.run_tracker"
	ManualSingleResolutionType      = "manual.single"
	FailedPermanentlyResolutionType = "failed.permanently"
)

// Resolve will take the Raw exercise string and parse out the various fields
// TODO: this really shouldn't be a method on the struct - frankly bad decisions
// TODO: this needs some testing BADLY
func (e *Exercise) Resolve(v *viper.Viper, db *gorm.DB) error {
	if e.Type == "skip.run_tracker" {
		d := &ExerciseDictionary{}
		if err := db.Where("url = ?", "https://exrx.net/Aerobic/Exercises/Run").First(d).Error; err != nil {
			return err
		}

		e.ExerciseDictionaries = []*ExerciseDictionary{d}
		e.ResolutionType = AutoRunTracker

		// TODO:  should we trust client as we currently do for distance/etc??? probably yes - just double  check

		return nil
	}

	parsedExercises, err := parser.Get().ResolveActivity(e.Raw)
	if err != nil {
		// try and determine some feedback we can give to the user as to what went wrong
		r, err := parser.Get().ResolveCorrective(e.Raw)
		if err == nil {
			// TODO: we should update resolution type once everone is on build 1.2
			e.CorrectiveCode = r.CorrectiveCode
			return nil
		}

		return err
	} else if len(parsedExercises) > 1 {
		r, err := parser.Get().ResolveCorrective(e.Raw)
		if err == nil {
			// TODO: we should update resolution type once everone is on build 1.2
			e.CorrectiveCode = r.CorrectiveCode
			return nil
		}

		// since we have multiple matches - we'll continue to see if we can determine what the parsed results are about
	}

	var res *parser.ParsedActivity

	// TODO: this if block is the ugliest piece of code in code history (i'm sorry)
	if len(parsedExercises) > 1 { // we got multiple matches from parser
		// now things get freaky - and fuckin slowwww =(

		resolved := []*parser.ParsedActivity{}
		exerciseDictionaries := []*ExerciseDictionary{}
		for _, p := range parsedExercises {
			parsedExerciseStr := parser.Get().RemoveStopPhrases(p.Captures["Exercise"])

			searchResults, err := SearchExerciseDictionaryWithRank(v, db, parsedExerciseStr, 0.05)
			if err != nil {
				return err
			} else if len(searchResults) > 0 {
				resolved = append(resolved, p)
				d := &ExerciseDictionary{}
				d.ID = searchResults[0].ExerciseDictionaryID
				d.Name = searchResults[0].ExerciseDictionaryName
				exerciseDictionaries = append(exerciseDictionaries, d)
			}
		}

		if len(resolved) != 1 {
			return fmt.Errorf("couldn't distinguish between multiple parse results: %s", utils.PrettyStringify(parsedExercises))
		}

		e.ExerciseDictionaries = exerciseDictionaries
		e.ResolutionType = AutoCompoundResolutionType
		res = resolved[0]

		// for backwards compatibility
		e.ExerciseDictionaryID = &exerciseDictionaries[0].ID
	} else { // we got 1 match from parser
		res = parsedExercises[0]
		parsedExerciseStr := parser.Get().RemoveStopPhrases(res.Captures["Exercise"])
		exerciseDictionaries := []*ExerciseDictionary{}

		searchResults, err := SearchExerciseDictionaryWithRank(v, db, parsedExerciseStr, 0.05)
		if err != nil {
			return err
		} else if len(searchResults) > 0 {
			d := &ExerciseDictionary{}
			d.ID = searchResults[0].ExerciseDictionaryID
			d.Name = searchResults[0].ExerciseDictionaryName

			exerciseDictionaries = append(exerciseDictionaries, d)

			e.ExerciseDictionaries = exerciseDictionaries

			if strings.EqualFold(d.Name, "Rest") {
				e.ResolutionType = AutoSpecialRestResolutionType
			} else {
				e.ResolutionType = AutoSingleResolutionType
			}

			// for backwards compatibility
			e.ExerciseDictionaryID = &exerciseDictionaries[0].ID
		} else {
			// now things get slow again as we try and find an exercise or exercises in the expression (but STRONGer match)

			subExercises, err := parser.Get().ResolveExercise(parsedExerciseStr)
			if err != nil {
				return err
			}

			for _, e := range subExercises {
				searchResults, err := SearchExerciseDictionaryWithRank(v, db, e, 0.065)
				if err != nil {
					return err
				} else if len(searchResults) > 0 {
					d := &ExerciseDictionary{}
					d.ID = searchResults[0].ExerciseDictionaryID
					d.Name = searchResults[0].ExerciseDictionaryName
					exerciseDictionaries = append(exerciseDictionaries, d)
				}
			}

			// we gotta match all exercises
			if len(subExercises) == len(exerciseDictionaries) && len(exerciseDictionaries) > 0 {
				e.ExerciseDictionaries = exerciseDictionaries
				e.ResolutionType = AutoCompoundResolutionType

				// for backwards compatibility
				e.ExerciseDictionaryID = &exerciseDictionaries[0].ID
			} else {
				// first double check that its not a corrective expression - reason we do this check pessemistically is because we want happy path to be quick
				r, err := parser.Get().ResolveCorrective(e.Raw)
				if err == nil {
					// TODO: we should update resolution type once everone is on build 1.2
					e.CorrectiveCode = r.CorrectiveCode
					return nil
				}
			}
		}
	}

	e.Type = res.ParseType
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

	cals, err := evalCalories(res.Captures)
	if err != nil {
		return err
	}

	e.ExerciseData.Sets = sets
	e.ExerciseData.Reps = reps
	e.ExerciseData.Weight = weight
	e.ExerciseData.Distance = distance
	e.ExerciseData.Time = time
	e.ExerciseData.Calories = cals

	return nil
}

type ExerciseData struct {
	HiddenModel
	Sets       int     `json:"sets"`
	Reps       int     `json:"reps"`
	Weight     float64 `json:"weight"`
	Time       uint    `json:"time"`
	Distance   float64 `json:"distance"`
	Calories   int     `json:"calories"`
	ExerciseID uint    `json:"exercise_id" gorm:"type:int REFERENCES exercises(id) ON DELETE CASCADE"`
}

func (ExerciseData) TableName() string {
	return "exercise_data"
}

// returns 0 if not specified
func evalCalories(captures map[string]string) (int, error) {
	calStr, ok := captures["Calories"]
	if !ok {
		return 0, nil
	}

	cals, err := strconv.Atoi(calStr)
	if err != nil {
		return 0, nil
	}

	return cals, nil
}

// returns 1 if not specified (always has to be greater than zero or metrics are fucked)
func evalSets(captures map[string]string) (int, error) {
	setStr, ok := captures["Sets"]
	if !ok {
		return 1, nil
	}

	sets, err := strconv.Atoi(setStr)
	if err != nil {
		return 0, nil
	}

	if sets < 1 {
		return 1, fmt.Errorf("Sets has to be a positive number greater than zero")
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

		standardizedRestPeriod, err := parser.UnitStandardize(restPeriodUnits, float64(restPeriod))
		if err != nil {
			return 0, err
		}

		return int(standardizedRestPeriod), nil
	}

	restPeriod, err := strconv.Atoi(restPeriodStr)
	if err != nil {
		return 0, err
	}

	standardizedRestPeriod, err := parser.UnitStandardize(restPeriodUnits, float64(restPeriod))
	if err != nil {
		return 0, err
	}

	return int(standardizedRestPeriod), nil
}

// return 0 if not specified
func evalLevel(captures map[string]string) (int, error) {
	levelStr, ok := captures["Level"]
	if !ok {
		return 0, nil
	}

	if strings.Contains(levelStr, "-") {
		levelTokens := strings.Split(levelStr, "-")
		if len(levelTokens) != 2 {
			return 0, fmt.Errorf("Level contains -, but doesn't have two level numbers. Eg of expected: 10-12")
		}

		level1, err := strconv.Atoi(levelTokens[0])
		level2, err := strconv.Atoi(levelTokens[1])

		if err != nil {
			return 0, err
		}

		return utils.MaxInt(level1, level2), nil
	}

	level, err := strconv.Atoi(levelStr)
	if err != nil {
		return 0, err
	}
	return level, nil
}

// returns 1 if not specified - (always has to be greater than zero or metrics are fucked)
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

	if reps < 1 {
		return 0, fmt.Errorf("Reps has to be positive number greater than zero")
	}

	return reps, nil
}

// returns 0 if not specified
func evalWeight(captures map[string]string) (float64, error) {
	weightStr, ok := captures["Weight"]
	if !ok {
		return 0, nil
	}

	unit := utils.GetStringOrDefault(captures["WeightUnits"], "pounds")

	weight, err := strconv.ParseFloat(weightStr, 64)
	if err != nil {
		return 0, err
	}

	standardized, err := parser.UnitStandardize(unit, weight)
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

	if strings.Contains(timeStr, "-") {
		timeTokens := strings.Split(timeStr, "-")
		if len(timeTokens) != 2 {
			return 0, fmt.Errorf("Time contains -, but doesn't have two numbers. Eg of expected: 10-15")
		}

		time1, err := strconv.Atoi(timeTokens[0])
		time2, err := strconv.Atoi(timeTokens[1])

		if err != nil {
			return 0, err
		}

		standardizedTime, err := parser.UnitStandardize(timeUnit, float64(utils.MaxInt(time1, time2)))

		if err != nil {
			return 0, err
		}

		return uint(standardizedTime), nil
	} else if strings.Contains(timeStr, ":") {
		timeTokens := strings.Split(timeStr, ":")
		if len(timeTokens) != 2 {
			return 0, fmt.Errorf("Time contains :, but doesnt' match expected format of: mm:ss")
		}

		mins, err := strconv.Atoi(timeTokens[0])
		secs, err := strconv.Atoi(timeTokens[1])

		if err != nil {
			return 0, err
		}

		standardizedTimeUnits, _ := parser.UnitClassify(timeUnit)

		standardizedFirstPart := 0.0
		standardizedSecondPart := 0.0

		if standardizedTimeUnits == parser.HourUnit {
			standardizedFirstPart, err = parser.UnitStandardize(parser.HourUnit, float64(mins))
			standardizedSecondPart, err = parser.UnitStandardize(parser.MinuteUnit, float64(secs))

			if err != nil {
				return 0, err
			}
		} else if standardizedTimeUnits == parser.MinuteUnit {
			standardizedFirstPart, err = parser.UnitStandardize(parser.MinuteUnit, float64(mins))
			standardizedSecondPart, err = parser.UnitStandardize(parser.SecondUnit, float64(secs))

			if err != nil {
				return 0, err
			}
		} else {
			standardizedFirstPart, err = parser.UnitStandardize(parser.MinuteUnit, float64(mins))
			standardizedSecondPart, err = parser.UnitStandardize(parser.SecondUnit, float64(secs))

			if err != nil {
				return 0, err
			}
		}

		standardizedTime := standardizedFirstPart + standardizedSecondPart

		return uint(standardizedTime), nil
	}

	time, err := strconv.Atoi(timeStr)
	if err != nil {
		return 0, err
	}

	standardizedTime, err := parser.UnitStandardize(timeUnit, float64(time))
	if err != nil {
		return 0, err
	}

	return uint(standardizedTime), nil
}

// returns 0 if not specified
func evalDistance(captures map[string]string) (float64, error) {
	if captures["Distance"] == "" {
		return 0, nil
	}

	unit := utils.GetStringOrDefault(captures["DistanceUnits"], "miles")

	distance, err := strconv.ParseFloat(captures["Distance"], 64)
	if err != nil {
		return 0, err
	}

	standardizedDist, err := parser.UnitStandardize(unit, distance)
	if err != nil {
		return 0, err
	}

	return standardizedDist, nil
}
