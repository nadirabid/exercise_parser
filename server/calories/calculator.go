package calories

import (
	"exercise_parser/models"
	"fmt"
	"math"

	"github.com/bearbin/go-age"
)

// TODO: update calories based on ROUNDS

// Calculate calories from workout
func CalculateFromUserWorkout(user *models.User, workout *models.Workout, dictionaries map[uint]*models.ExerciseDictionary) (int, error) {
	totalCalories := 0.0

	for _, e := range workout.Exercises {
		if e.ExerciseData.Calories > 0 { // user specifed calories of exercise takes precedence (if specified)
			totalCalories += float64(e.ExerciseData.Calories) * float64(e.ExerciseData.Reps) * float64(e.ExerciseData.Sets)
			continue
		}

		met := float64(0.0)

		if e.ExerciseDictionaryID != nil {
			d, ok := dictionaries[*e.ExerciseDictionaryID]
			if !ok {
				return 0, fmt.Errorf("dictionary id %d not found", e.ExerciseDictionaryID)
			}

			met = metFromDictionaryUrl(d.URL, metIntensityFromExercise(e))
		}

		time := float64(e.ExerciseData.Time)

		if time == 0 {
			time += calculateSecondsFromDistance(e.ExerciseData.Distance)
			time += calculateSecondsFromSetsAndReps(e.ExerciseData.Sets, e.ExerciseData.Reps, e.ExerciseData.Weight)
		}

		weight := user.Weight
		if weight == 0 {
			if user.IsMale {
				weight = 86.1826 // kg
			} else {
				weight = 68 // kg
			}
		}

		height := user.Height
		ageYears := float64(0.0)
		if user.Birthdate != nil {
			ageYears = float64(age.Age(*user.Birthdate))
		}

		if height != 0 && ageYears != 0 {
			totalCalories += float64(calculateCalsFromCorrectedMET(met, weight, height, ageYears, time, user.IsMale))
		} else {
			totalCalories += float64(calculatedCalsFromStandardMET(met, weight, time))
		}
	}

	return int(math.Round(totalCalories)), nil
}

// Obese: https://www.nature.com/articles/ijo201422
// CORRECTED MET: http://www.umass.edu/physicalactivity/newsite/publications/Sarah%20Keadle/papers/1.pdf
// https://download.lww.com/wolterskluwer_vitalstream_com/PermaLink/MSS/A/MSS_43_8_2011_06_13_AINSWORTH_202093_SDC1.pdf
// https://sites.google.com/site/compendiumofphysicalactivities/Activity-Categories/new-activity-updates
// 1 MET = 1 kcal/kg/hr - there seem to be other definitions so fuck me - MET maybe useless
// weight in kg
// time in hrs
func calculatedCalsFromStandardMET(met float64, weightKg float64, timeSeconds float64) float64 {
	return met * weightKg * (timeSeconds / (60 * 60))
}

func calculateCalsFromCorrectedMET(met, weightKg, heightCm, ageYr, timeSeconds float64, male bool) float64 {
	if male {
		return met * calculateMaleBMR(weightKg, heightCm, ageYr) * (timeSeconds / (24 * 60 * 60))
	}

	return met * calculateFemaleBMR(weightKg, heightCm, ageYr) * (timeSeconds / (24 * 60 * 60))
}

func calculateMaleBMR(weightKg float64, heightCm float64, ageYr float64) float64 {
	return (10 * weightKg) + (6.25 * heightCm) - (5 * ageYr) + 5
}

func calculateFemaleBMR(weightKg float64, heightCm float64, ageYr float64) float64 {
	return (10 * weightKg) + (6.25 * heightCm) - (5 * ageYr) - 161
}

// TODO: if we can add a notion of "heigher/lower/average weight used for a given user"  - the time estimate could be better
// When you don't have time for a given exercise - use this to estimate an on average lower bound time estimate
func calculateSecondsFromSetsAndReps(sets, reps int, weight float64) float64 {
	// assume each rep takes 4 seconds
	// assume eeach break between sets is 90 seconds

	setsMultiplier := int(40 + (weight / 2))
	return float64((reps * 4) + (sets * setsMultiplier))
}

func calculateSecondsFromDistance(distanceMeters float64) float64 {
	return (60*5 + 37.5) * (distanceMeters / 1000) // assume 9 min mile (5 min 37.5 sec per km)
}
