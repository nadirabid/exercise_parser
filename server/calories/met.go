package calories

import (
	"exercise_parser/models"
	"strings"
)

// determine MET from dictionary URL
// 2011 compendium of activities: https://download.lww.com/wolterskluwer_vitalstream_com/PermaLink/MSS/A/MSS_43_8_2011_06_13_AINSWORTH_202093_SDC1.pdf
func metFromDictionaryUrl(dictionaryURL string, intensity int) float32 {
	switch dictionaryURL {
	case
		"https://exrx.net/Aerobic/Exercises/UprightCycle",
		"https://exrx.net/Aerobic/Exercises/CycleCrossTrainer",
		"https://exrx.net/Aerobic/Exercises/RecumbantCycle":
		if intensity == 1 {
			return 3.5 // 02011
		} else if intensity == 2 {
			return 6.8 // 02012
		} else if intensity == 3 {
			return 8.8 // 02013
		} else if intensity == 4 {
			return 11 // 02014
		} else if intensity >= 5 {
			return 14 // 02015
		}
	case
		"https://exrx.net/WeightExercises/PectoralSternal/BWPushup",
		"https://exrx.net/WeightExercises/LatissimusDorsi/BWPullup",
		"https://exrx.net/Aerobic/Exercises/JumpingJack",
		"https://exrx.net/WeightExercises/Quadriceps/DBLunge",
		"https://exrx.net/WeightExercises/RectusAbdominis/BWCrunch",
		"https://exrx.net/WeightExercises/Quadriceps/BWLunge",
		"https://exrx.net/WeightExercises/RectusAbdominis/BWCrunchUp",
		"https://exrx.net/Aerobic/Exercises/JumpRopeSingleHop",
		"https://exrx.net/WeightExercises/RectusAbdominis/BWSitUp":
		if intensity == 1 {
			return 3.5 // 02054
		} else if intensity == 2 {
			return 5 // 02052
		} else if intensity >= 3 {
			return 6 // 02050
		}
	case
		"https://exrx.net/Aerobic/Exercises/RowErgometer",
		"https://exrx.net/Aerobic/Exercises/RowErgometerCanoe":
		if intensity == 1 {
			return 4.8 // 02071
		} else if intensity == 2 {
			return 6.0 // 02070
		}
	case
		"https://exrx.net/Aerobic/Exercises/Jog",
		"https://exrx.net/Aerobic/Exercises/TreadmillRun",
		"https://exrx.net/Aerobic/Exercises/Run":
		if intensity == 1 {
			return 6.0 // 12029
		} else if intensity == 2 {
			return 8.3 // 12030
		} else if intensity == 3 {
			return 9.0 // 12040
		} else if intensity == 4 {
			return 9.8 // 12050
		} else if intensity == 5 {
			return 10.5 // 12060
		} else if intensity == 6 {
			return 11 // 12070
		} else if intensity == 7 {
			return 11.5 // 12080 (8 min mile)
		} else if intensity == 8 {
			return 11.8 // 12090 (7.5 min mile)
		} else if intensity == 9 {
			return 12.3 // 12100 (7 min mile)
		} else if intensity == 10 {
			return 12.8 // 12110 (6.5 min mile)
		} else if intensity == 11 {
			return 14.5 // 12120 (6 min mile)
		} else if intensity == 12 {
			return 16 // 12130 (5.5 min mile)
		} else if intensity >= 13 {
			return 19 // 12132 (5 min mile)
		}
	}

	if strings.Contains(dictionaryURL, "/Aerobic") || strings.Contains(dictionaryURL, "/Plyometric") {
		if intensity == 1 {
			return 3.5
		} else if intensity >= 2 {
			return 8
		}
	}

	if strings.Contains(dictionaryURL, "/Weight") {
		if intensity == 1 {
			return 3.5 // 02054
		} else if intensity == 2 {
			return 5.0 // 02052
		} else if intensity >= 3 {
			return 6 // 02050
		}
	}

	return 1.0
}

func metIntensityFromExercise(e models.Exercise) int {
	time := e.ExerciseData.Time

	if time == 0 {
		return 2
	}

	distanceIntensity := 0

	if e.ExerciseData.Distance > 0 {
		distanceIntensity = int(e.ExerciseData.Distance/1000) * 50 / int(time/60) // (km * 50) / mins
	}

	repsIntensity := 0

	if e.ExerciseData.Reps > 1 && e.ExerciseData.Sets > 1 {
		m := 1.5
		totalReps := e.ExerciseData.Reps * e.ExerciseData.Sets
		repsIntensity = totalReps / int(float64(time/60)*m)
	}

	return distanceIntensity + repsIntensity
}
