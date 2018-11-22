package server

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestWeightedExercise(t *testing.T) {
	tricepCurls1 := map[string]string{"Exercise": "tricep curls", "Sets": "3", "Reps": "3"}

	t.Run("{Sets:Number} {Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpressions("3 3 tricep curls", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number} {Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpressions("3 3 of tricep curls", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpressions("3x3 tricep curls", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number} x {Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpressions("3 x 3 tricep curls", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpressions("3x3 of tricep curls", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number} x {Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpressions("3 x 3 of tricep curls", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number} by {Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpressions("3 by 3 tricep curls", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number} by {Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpressions("3 by 3 of tricep curls", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number} sets of {Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpressions("3 sets of 3 tricep curls", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number} sets of {Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpressions("3 sets of 3 of tricep curls", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:Number} sets of {Reps:Number} reps {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpressions("3 sets of 3 reps tricep curls", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Sets:number} sets of {Reps:Number} reps of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpressions("3 sets of 3 reps of tricep curls", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exericse:String} {Sets:Number} {Reps:Number}", func(t *testing.T) {
		parsed := resolveExpressions("tricep curls 3 3", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exericse:String} {Sets:Number}, {Reps:Number}", func(t *testing.T) {
		parsed := resolveExpressions("tricep curls, 3 3", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exericse:String} {Sets:Number}x{Reps:Number}", func(t *testing.T) {
		parsed := resolveExpressions("tricep curls 3x3", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exericse:String}, {Sets:Number}x{Reps:Number}", func(t *testing.T) {
		parsed := resolveExpressions("tricep curls, 3x3", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exercise:String}, {Sets:Number} by {Reps:Number}", func(t *testing.T) {
		parsed := resolveExpressions("tricep curls, 3 by 3", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exercise:String} {Sets:Number} sets {Reps:Number} reps", func(t *testing.T) {
		parsed := resolveExpressions("tricep curls 3 sets 3 reps", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exercise:String}, {Sets:Number} sets {Reps:Number} reps", func(t *testing.T) {
		parsed := resolveExpressions("tricep curls, 3 sets 3 reps", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exercise:String} {Sets:Number}, sets of {Reps:Number}", func(t *testing.T) {
		parsed := resolveExpressions("tricep curls, 3 sets of 3", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})

	t.Run("{Exercise:String} {Sets:Number}, sets of {Reps:Number} reps", func(t *testing.T) {
		parsed := resolveExpressions("tricep curls, 3 sets of 3 reps", weightedExerciseExpressions())
		assert.Equal(t, tricepCurls1, parsed.Captures)
	})
}

func TestDistanceExercise(t *testing.T) {
	running1 := map[string]string{"Exercise": "running", "Distance": "1.55", "Units": "miles"}

	t.Run("{Exercise:String} {Distance:Number} {Units:String}", func(t *testing.T) {
		parsed := resolveExpressions("running 1.55 miles", distanceExerciseExpressions())
		assert.Equal(t, running1, parsed.Captures)
	})

	t.Run("{Exercise:String} {Distance:Number}{Units:String}", func(t *testing.T) {
		parsed := resolveExpressions("running 1.55miles", distanceExerciseExpressions())
		assert.Equal(t, running1, parsed.Captures)
	})

	t.Run("{Exercise:String}, {Distance:Number}{Units:String}", func(t *testing.T) {
		parsed := resolveExpressions("running, 1.55miles", distanceExerciseExpressions())
		assert.Equal(t, running1, parsed.Captures)
	})

	t.Run("{Exercise:String} for {Distance:Number} {Units:String}", func(t *testing.T) {
		parsed := resolveExpressions("running for 1.55 miles", distanceExerciseExpressions())
		assert.Equal(t, running1, parsed.Captures)
	})

	t.Run("{Exericse:String} for {Distance:Number}{Units:String}", func(t *testing.T) {
		parsed := resolveExpressions("running for 1.55 miles", distanceExerciseExpressions())
		assert.Equal(t, running1, parsed.Captures)
	})

	t.Run("{Distance:Float} {Units:String} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpressions("1.55 miles running", distanceExerciseExpressions())
		assert.Equal(t, running1, parsed.Captures)
	})

	t.Run("{Distance:Float} {Units:String}, of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpressions("1.55 miles, running", distanceExerciseExpressions())
		assert.Equal(t, running1, parsed.Captures)
	})

	t.Run("{Distance:Float} {Units:String} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveExpressions("1.55 miles of running", distanceExerciseExpressions())
		assert.Equal(t, running1, parsed.Captures)
	})

	running2 := map[string]string{"Exercise": "ran", "Distance": "5", "Units": "miles", "Time": "10 minutes"}

	t.Run("{Exercise:String} {Distance:Float} {Units:String} in {Time:String}", func(t *testing.T) {
		parsed := resolveExpressions("Ran 5 miles in 10 minutes", distanceExerciseExpressions())
		assert.Equal(t, running2, parsed.Captures)
	})

	running3 := map[string]string{"Exercise": "ran", "Distance": "0.5", "Units": "miles", "Time": "10 minutes"}

	t.Run("{Exercise:String} {Distance:Float} {Units:String} in {Time:String}", func(t *testing.T) {
		parsed := resolveExpressions("Ran 0.5 miles in 10 minutes", distanceExerciseExpressions())
		assert.Equal(t, running3, parsed.Captures)
	})
}
