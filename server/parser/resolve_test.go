package parser

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestWeightedExercise(t *testing.T) {
	tricepCurls1 := map[string]string{"Exercise": "tricep curls", "Sets": "3", "Reps": "3"}

	t.Run("{Sets:Number} {Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3 3 tricep curls")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number} {Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3 3 of tricep curls")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3x3 tricep curls")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number} x {Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3 x 3 tricep curls")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3x3 of tricep curls")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number} x {Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3 x 3 of tricep curls")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number} by {Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3 by 3 tricep curls")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number} by {Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3 by 3 of tricep curls")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number} by {Reps:Number} sets of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3 by 3 sets of tricep curls")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number} sets of {Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3 sets of 3 tricep curls")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number} sets of {Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3 sets of 3 of tricep curls")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number} sets of {Reps:Number} reps {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3 sets of 3 reps tricep curls")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:number} sets of {Reps:Number} reps of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3 sets of 3 reps of tricep curls")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exericse:String} {Sets:Number} {Reps:Number}", func(t *testing.T) {
		parsed := resolveExpUtil("tricep curls 3 3")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exericse:String} {Sets:Number}, {Reps:Number}", func(t *testing.T) {
		parsed := resolveExpUtil("tricep curls, 3 3")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exericse:String} {Sets:Number}x{Reps:Number}", func(t *testing.T) {
		parsed := resolveExpUtil("tricep curls 3x3")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exericse:String}, {Sets:Number}x{Reps:Number}", func(t *testing.T) {
		parsed := resolveExpUtil("tricep curls, 3x3")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exercise:String}, {Sets:Number} by {Reps:Number}", func(t *testing.T) {
		parsed := resolveExpUtil("tricep curls, 3 by 3")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exercise:String} {Sets:Number} sets {Reps:Number} reps", func(t *testing.T) {
		parsed := resolveExpUtil("tricep curls 3 sets 3 reps")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exercise:String}, {Sets:Number} sets {Reps:Number} reps", func(t *testing.T) {
		parsed := resolveExpUtil("tricep curls, 3 sets 3 reps")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exercise:String} {Sets:Number}, sets of {Reps:Number}", func(t *testing.T) {
		parsed := resolveExpUtil("tricep curls, 3 sets of 3")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exercise:String} {Sets:Number}, sets of {Reps:Number} reps", func(t *testing.T) {
		parsed := resolveExpUtil("tricep curls, 3 sets of 3 reps")
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	tricepCurls2 := map[string]string{"Exercise": "tricep curls", "Sets": "3", "Reps": "3", "Weight": "25"}

	t.Run("{Sets:Number} {Reps:Number} {Weight:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3 3 25 tricep curls")
		assert.Equal(t, tricepCurls2, parsed.Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number}x{Weight:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3x3x25 tricep curls")
		assert.Equal(t, tricepCurls2, parsed.Captures)
	})

	t.Run("{Sets:Number} x {Reps:Number} x {Weight:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3 x 3 x 25 tricep curls")
		assert.Equal(t, tricepCurls2, parsed.Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number}x{Weight:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3x3x25 of tricep curls")
		assert.Equal(t, tricepCurls2, parsed.Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number} at {Weight:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3x3 at 25 tricep curls")
		assert.Equal(t, tricepCurls2, parsed.Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number} at {Weight:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("3x3 at 25 of tricep curls")
		assert.Equal(t, tricepCurls2, parsed.Captures)
	})

	units := []string{"kg", "kilos", "kilogram", "kilograms", "lb", "lbs", "pound", "pounds"}

	for _, u := range units {
		tricepCurls3 := map[string]string{
			"Exercise": "tricep curls",
			"Sets":     "3",
			"Reps":     "3",
			"Weight":   "25",
			"Units":    u,
		}

		t.Run("{Sets:Number} {Reps:Number} {Weight:Number}{Units} {Exercise:String}", func(t *testing.T) {
			parsed := resolveExpUtil(fmt.Sprintf("3 3 25%s tricep curls", u))
			assert.Equal(t, tricepCurls3, parsed.Captures)
		})

		t.Run("{Sets:Number} {Reps:Number} {Weight:Number} {Units} {Exercise:String}", func(t *testing.T) {
			parsed := resolveExpUtil(fmt.Sprintf("3 3 25 %s tricep curls", u))
			assert.Equal(t, tricepCurls3, parsed.Captures)
		})

		t.Run("{Sets:Number}x{Reps:Number}x{Weight:Number}{Units} {Exercise:String}", func(t *testing.T) {
			parsed := resolveExpUtil(fmt.Sprintf("3x3x25%s tricep curls", u))
			assert.Equal(t, tricepCurls3, parsed.Captures)
		})

		t.Run("{Sets:Number}x{Reps:Number}x{Weight:Number} {Units} {Exercise:String}", func(t *testing.T) {
			parsed := resolveExpUtil(fmt.Sprintf("3x3x25 %s tricep curls", u))
			assert.Equal(t, tricepCurls3, parsed.Captures)
		})

		t.Run("{Sets:Number}x{Reps:Number}x{Weight:Number}{Units} of {Exercise:String}", func(t *testing.T) {
			parsed := resolveExpUtil(fmt.Sprintf("3x3x25%s of tricep curls", u))
			assert.Equal(t, tricepCurls3, parsed.Captures)
		})

		t.Run("{Sets:Number}x{Reps:Number} at {Weight:Number}{Units} {Exercise:String}", func(t *testing.T) {
			parsed := resolveExpUtil(fmt.Sprintf("3x3 at 25%s tricep curls", u))
			assert.Equal(t, tricepCurls3, parsed.Captures)
		})

		t.Run("{Sets:Number}x{Reps:Number} at {Weight:Number}{Units} of {Exercise:String}", func(t *testing.T) {
			parsed := resolveExpUtil(fmt.Sprintf("3x3 at 25%s of tricep curls", u))
			assert.Equal(t, tricepCurls3, parsed.Captures)
		})

		delimiter := []string{
			"-", "- ", " -", " - ",
			",", ", ", " ,", " , ",
			" ", "  ",
		}

		for _, d := range delimiter {
			t.Run("{Sets:Number}x{Reps:Number} {Exercise:String} (Delimiter) {Weight:Number}{Units}", func(t *testing.T) {
				parsed := resolveExpUtil(fmt.Sprintf("3x3 tricep curls%s25%s", d, u))
				assert.Equal(t, tricepCurls3, parsed.Captures)
			})

			t.Run("{Exercise:String} {Sets:Number}x{Reps:Number} {Delimiter) {Weight:Number} {Units}", func(t *testing.T) {
				parsed := resolveExpUtil(fmt.Sprintf("tricep curls 3x3%s25%s", d, u))
				assert.Equal(t, tricepCurls3, parsed.Captures)
			})
		}
	}
}

func TestDistanceExercise(t *testing.T) {
	running1 := map[string]string{"Exercise": "running", "Distance": "1.55", "Units": "miles"}

	t.Run("{Exercise:String} {Distance:Number} {Units:String}", func(t *testing.T) {
		parsed := resolveExpUtil("running 1.55 miles")
		assert.Equal(t, running1, parsed.Captures)
	})

	t.Run("{Exercise:String} {Distance:Number}{Units:String}", func(t *testing.T) {
		parsed := resolveExpUtil("running 1.55miles")
		assert.Equal(t, running1, parsed.Captures)
	})

	t.Run("{Exercise:String}, {Distance:Number}{Units:String}", func(t *testing.T) {
		parsed := resolveExpUtil("running, 1.55miles")
		assert.Equal(t, running1, parsed.Captures)
	})

	t.Run("{Exercise:String} for {Distance:Number} {Units:String}", func(t *testing.T) {
		parsed := resolveExpUtil("running for 1.55 miles")
		assert.Equal(t, running1, parsed.Captures)
	})

	t.Run("{Exericse:String} for {Distance:Number}{Units:String}", func(t *testing.T) {
		parsed := resolveExpUtil("running for 1.55 miles")
		assert.Equal(t, running1, parsed.Captures)
	})

	t.Run("{Distance:Float} {Units:String} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("1.55 miles running")
		assert.Equal(t, running1, parsed.Captures)
	})

	t.Run("{Distance:Float} {Units:String}, of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("1.55 miles, running")
		assert.Equal(t, running1, parsed.Captures)
	})

	t.Run("{Distance:Float} {Units:String} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpUtil("1.55 miles of running")
		assert.Equal(t, running1, parsed.Captures)
	})

	running2 := map[string]string{"Exercise": "ran", "Distance": "5", "Units": "miles", "Time": "10", "TimeUnits": "minutes"}
	running3 := map[string]string{"Exercise": "ran", "Distance": "0.5", "Units": "miles", "Time": "10", "TimeUnits": "minutes"}

	t.Run("{Exercise:String} {Distance:Number} {Units:String} in {Time:Number}", func(t *testing.T) {
		parsed := resolveExpUtil("Ran 5 miles in 10 minutes")
		assert.Equal(t, running2, parsed.Captures)
	})

	t.Run("{Exercise:String} {Distance:Float} {Units:String} in {Time:Number}", func(t *testing.T) {
		parsed := resolveExpUtil("Ran 0.5 miles in 10 minutes")
		assert.Equal(t, running3, parsed.Captures)
	})

	delimiter := []string{
		"-", "- ", " -", " - ",
		",", ", ", " ,", " , ",
		" ", "  ",
	}

	for _, d := range delimiter {
		t.Run("{Exercise:String} {Distance:Number} {Units:String} (Delimiter) {Time:Number}", func(t *testing.T) {
			parsed := resolveExpUtil(fmt.Sprintf("Ran 5 miles%s10 minutes", d))
			assert.Equal(t, running2, parsed.Captures)
		})

		t.Run("{Exercise:String} {Distance:Float} {Units:String} (Delimiter) {Time:Number}", func(t *testing.T) {
			parsed := resolveExpUtil(fmt.Sprintf("Ran 0.5 miles%s10 minutes", d))
			assert.Equal(t, running3, parsed.Captures)
		})
	}
}

func resolveExpUtil(exercise string) *parsedExercise {
	distance := distanceExerciseExpressions()
	weighted := weightedExerciseExpressions()

	s := append(distance, weighted...)

	return resolveExpressions(exercise, s)
}
