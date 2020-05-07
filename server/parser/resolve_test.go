package parser

import (
	"exercise_parser/utils"
	"fmt"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestFutureSupport(t *testing.T) {
	t.Run("Farmers walk 20 feet", func(t *testing.T) {
		test := map[string]string{"Exercise": "farmers walk", "Distance": "20", "DistanceUnits": "feet"}
		parsed := resolveAllTestUtil("Farmers walk 20 feet")
		assert.Equal(t, test, parsed[0].Captures)
	})
}

func TestWeightedExercise(t *testing.T) {
	delimiter := []string{
		"-", "- ", " -", " - ",
		",", ", ", " ,", " , ",
		" ", "  ",
	}

	units := []string{"kg", "kilos", "kilogram", "kilograms", "lb", "lbs", "pound", "pounds"}

	kettlebellSwings1 := map[string]string{"Exercise": "kettlebell swings", "Reps": "50"}
	kettlebellSwings2 := map[string]string{"Exercise": "kettlebell swings", "Reps": "25-50"}
	kettlebellSwings3 := map[string]string{"Exercise": "kettlebell swings", "Reps": "12", "Weight": "25", "WeightUnits": "lbs"}
	kettlebellSwings4 := map[string]string{"Exercise": "kettlebell swings", "Reps": "10-12", "Weight": "25", "WeightUnits": "lbs"}
	squatJumps1 := map[string]string{"Exercise": "squat jumps", "Reps": "20", "Sets": "5"}
	tricepCurls1 := map[string]string{"Exercise": "tricep curls", "Sets": "3", "Reps": "3"}

	for _, d := range delimiter {
		t.Run("{Reps:Number} (Delimiter) {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("50%skettlebell swings", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, kettlebellSwings1, parsed[0].Captures)
		})

		t.Run("{Reps:Number}-{Reps:Number} (Delimiter) {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("25-50%skettlebell swings", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, kettlebellSwings2, parsed[0].Captures)
		})

		t.Run("{Reps:Number} (Delimiter) {Exercise:String} (Delimiter) {Weight}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("12%skettlebell swings%s25lbs", d, d))
			assert.Equal(t, parsed[0].Captures, kettlebellSwings3)
		})

		t.Run("{Reps:Number}-{Reps:Number} (Delimiter) {Exercise:String} (Delimiter) {Weight}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("10-12%skettlebell swings%s25lbs", d, d))
			assert.Equal(t, parsed[0].Captures, kettlebellSwings4)
		})

		for _, d2 := range delimiter {
			t.Run("{Reps:Number} (Delimiter) {Exercise:String} (Delimiter) {Sets:Number} sets", func(t *testing.T) {
				parsed := resolveAllTestUtil(fmt.Sprintf("20%ssquat jumps%s5 sets", d, d2))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, squatJumps1, parsed[0].Captures)
			})
		}
	}

	t.Run("{Sets:Number} {Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3 3 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} {Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3 3 of tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3x3 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} x {Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3 x 3 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3x3 of tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} x {Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3 x 3 of tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} by {Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3 by 3 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} by {Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3 by 3 of tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} by {Reps:Number} sets of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3 by 3 sets of tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} sets of {Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3 sets of 3 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} sets of {Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3 sets of 3 of tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} sets of {Reps:Number} reps {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3 sets of 3 reps tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:number} sets of {Reps:Number} reps of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3 sets of 3 reps of tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Exericse:String} {Sets:Number} {Reps:Number}", func(t *testing.T) {
		parsed := resolveAllTestUtil("tricep curls 3 3")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	for _, d := range delimiter {
		t.Run("{Exericse:String} (Delimiter) {Sets:Number} {Reps:Number}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("tricep curls%s3 3", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls1, parsed[0].Captures)
		})

		t.Run("{Exericse:String} (Delimiter) {Sets:Number}x{Reps:Number}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("tricep curls%s3x3", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls1, parsed[0].Captures)
		})

		t.Run("{Exercise:String} (Delimiter) {Sets:Number} by {Reps:Number}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("tricep curls%s3 by 3", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls1, parsed[0].Captures)
		})

		t.Run("{Exercise:String} (Delimiter) {Sets:Number} sets {Reps:Number} reps", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("tricep curls%s3 sets 3 reps", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls1, parsed[0].Captures)
		})

		t.Run("{Exercise:String} (Delimiter) {Sets:Number} sets of {Reps:Number}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("tricep curls%s3 sets of 3", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls1, parsed[0].Captures)
		})

		t.Run("{Exercise:String} (Delimiter) {Sets:Number}, sets of {Reps:Number} reps", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("tricep curls%s3 sets of 3 reps", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls1, parsed[0].Captures)
		})

		for _, u := range units {
			weightedPullups1 := map[string]string{"Exercise": "weighted pull-ups", "Weight": "25", "WeightUnits": u, "Sets": "2", "Reps": "8"}
			t.Run("{Exercise:String} (Delimiter) {Weight:Number}{WeightUnits} (Delimiter) {Sets:Number}x{Reps:Number}", func(t *testing.T) {
				parsed := resolveAllTestUtil(fmt.Sprintf("Weighted pull-ups%s25%s%s2x8", d, u, d))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, weightedPullups1, parsed[0].Captures)
			})

			t.Run("{Exercise:String} (Delimiter) {Weight:Number}{WeightUnits} (Delimiter) {Sets:Number}x{Reps:Number}", func(t *testing.T) {
				parsed := resolveAllTestUtil(fmt.Sprintf("Weighted pull-ups%s25%sdumbbell%s2x8", d, u, d))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, weightedPullups1, parsed[0].Captures)
			})
		}

		jumpRope1 := map[string]string{"Exercise": "jumping rope", "Reps": "200"}
		for _, d := range delimiter {
			t.Run("{Exercise:String} (Delimiter) {Reps:Number}", func(t *testing.T) {
				parsed := resolveAllTestUtil(fmt.Sprintf("Jumping rope%s200", d))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, jumpRope1, parsed[0].Captures)
			})
		}
	}

	tricepCurls2 := map[string]string{"Exercise": "tricep curls", "Sets": "3", "Reps": "3", "Weight": "25", "WeightUnits": ""}

	t.Run("{Sets:Number} {Reps:Number} {Weight:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3 3 25 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls2, parsed[0].Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number}x{Weight:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3x3x25 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls2, parsed[0].Captures)
	})

	t.Run("{Sets:Number} x {Reps:Number} x {Weight:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3 x 3 x 25 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls2, parsed[0].Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number}x{Weight:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3x3x25 of tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls2, parsed[0].Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number} at {Weight:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3x3 at 25 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls2, parsed[0].Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number} at {Weight:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllTestUtil("3x3 at 25 of tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls2, parsed[0].Captures)
	})

	for _, u := range units {
		tricepCurls3 := map[string]string{
			"Exercise":    "tricep curls",
			"Sets":        "3",
			"Reps":        "3",
			"Weight":      "25",
			"WeightUnits": u,
		}

		t.Run("{Sets:Number} {Reps:Number} {Weight:Number}{WeightUnits} {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("3 3 25%s tricep curls", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls3, parsed[0].Captures)
		})

		t.Run("{Sets:Number} {Reps:Number} {Weight:Number} {WeightUnits} {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("3 3 25 %s tricep curls", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls3, parsed[0].Captures)
		})

		t.Run("{Sets:Number}x{Reps:Number}x{Weight:Number}{WeightUnits} {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("3x3x25%s tricep curls", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls3, parsed[0].Captures)
		})

		t.Run("{Sets:Number}x{Reps:Number}x{Weight:Number} {WeightUnits} {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("3x3x25 %s tricep curls", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls3, parsed[0].Captures)
		})

		t.Run("{Sets:Number}x{Reps:Number}x{Weight:Number}{WeightUnits} of {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("3x3x25%s of tricep curls", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls3, parsed[0].Captures)
		})

		t.Run("{Sets:Number}x{Reps:Number} at {Weight:Number}{WeightUnits} {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("3x3 at 25%s tricep curls", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls3, parsed[0].Captures)
		})

		t.Run("{Sets:Number}x{Reps:Number} at {Weight:Number}{WeightUnits} of {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("3x3 at 25%s of tricep curls", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls3, parsed[0].Captures)
		})

		bilateralRaise1 := map[string]string{"Exercise": "bilateral raise", "Reps": "3", "Weight": "145", "WeightUnits": u}

		t.Run("{Exercise:String} {Reps:Number}x{Weight:number}{WeightUnits}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("Bilateral raise 3x145%s", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, bilateralRaise1, parsed[0].Captures)
		})

		for _, d := range delimiter {
			t.Run("{Sets:Number}x{Reps:Number} {Exercise:String} (Delimiter) {Weight:Number}{WeightUnits}", func(t *testing.T) {
				parsed := resolveAllTestUtil(fmt.Sprintf("3x3 tricep curls%s25%s", d, u))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, tricepCurls3, parsed[0].Captures)
			})

			t.Run("{Exercise:String} {Sets:Number}x{Reps:Number} {Delimiter) {Weight:Number} {WeightUnits}", func(t *testing.T) {
				parsed := resolveAllTestUtil(fmt.Sprintf("tricep curls 3x3%s25%s", d, u))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, tricepCurls3, parsed[0].Captures)
			})
		}
	}
}

func TestDistanceExercise(t *testing.T) {
	running4 := map[string]string{"Exercise": "ran", "Time": "5", "TimeUnits": "mins"}

	delimiter := []string{
		"-", "- ", " -", " - ",
		",", ", ", " ,", " , ",
		" ", "  ",
	}

	distanceUnits := []string{
		"ft", "foot", "feet", "mi", "mile", "miles", "m", "meter", "meters", "kilometer", "kilometers", "km",
	}

	t.Run("{Exercise:String} for {Time:Number} {TimeUnits}", func(t *testing.T) {
		parsed := resolveAllTestUtil("ran for 5 mins")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, running4, parsed[0].Captures)
	})

	for _, d := range delimiter {
		t.Run("{Exercise:String} (Delimiter) {Time:Number} {TimeUnits}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("ran%s5 mins", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, running4, parsed[0].Captures)
		})
	}

	for _, u := range distanceUnits {
		running1 := map[string]string{"Exercise": "running", "Distance": "1.55", "DistanceUnits": u}
		running2 := map[string]string{"Exercise": "ran", "Distance": "5", "DistanceUnits": u, "Time": "10", "TimeUnits": "minutes"}
		running3 := map[string]string{"Exercise": "ran", "Distance": "0.5", "DistanceUnits": u, "Time": "10", "TimeUnits": "minutes"}

		fmt.Println(running1)
		fmt.Println(running2)
		fmt.Println(running3)

		t.Run("{Exercise:String} {Distance:Number} {DistanceUnits}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("running 1.55 %s", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, running1, parsed[0].Captures)
		})

		t.Run("{Exercise:String} {Distance:Number}{DistanceUnits}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("running 1.55%s", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, running1, parsed[0].Captures)
		})

		t.Run("{Exercise:String}, {Distance:Number}{DistanceUnits}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("running, 1.55%s", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, running1, parsed[0].Captures)
		})

		t.Run("{Exercise:String} for {Distance:Number} {DistanceUnits}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("running for 1.55 %s", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, running1, parsed[0].Captures)
		})

		t.Run("{Exericse:String} for {Distance:Number}{DistanceUnits}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("running for 1.55 %s", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, running1, parsed[0].Captures)
		})

		t.Run("{Distance:Float} {DistanceUnits} of {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("1.55 %s running", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, running1, parsed[0].Captures)
		})

		t.Run("{Distance:Float} {DistanceUnits}, of {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("1.55 %s, running", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, running1, parsed[0].Captures)
		})

		t.Run("{Distance:Float} {DistanceUnits} of {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("1.55 %s of running", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, running1, parsed[0].Captures)
		})

		t.Run("{Exercise:String} {Distance:Float} {DistanceUnits} in {Time:Number} {TimeUnits}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("Ran 5 %s in 10 minutes", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, running2, parsed[0].Captures)
		})

		t.Run("{Exercise:String} {Distance:Float} {DistanceUnits} in {Time:Number} {TimeUnits}", func(t *testing.T) {
			parsed := resolveAllTestUtil(fmt.Sprintf("Ran 0.5 %s in 10 minutes", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, running3, parsed[0].Captures)
		})

		for _, d := range delimiter {
			t.Run("{Exercise:String} {Distance:Float} {DistanceUnits} (Delimiter) {Time:Number} {TimeUnits}", func(t *testing.T) {
				parsed := resolveAllTestUtil(fmt.Sprintf("Ran 5 %s%s10 minutes", u, d))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, running2, parsed[0].Captures)
			})

			t.Run("{Exercise:String} {Distance:Float} {DistanceUnits} (Delimiter) {Time:Number} {TimeUnits}", func(t *testing.T) {
				parsed := resolveAllTestUtil(fmt.Sprintf("Ran 0.5 %s%s10 minutes", u, d))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, running3, parsed[0].Captures)
			})
		}
	}
}

// TODO: this function is dangerous - we should use resolveExpression
func resolveAllTestUtil(exercise string) []*parsedExercise {
	distance := distanceExerciseExpressions()
	weighted := weightedExerciseExpressions()
	regexpSet := append(distance, weighted...)

	exercise = strings.Trim(strings.ToLower(exercise), " ")

	allParsed := []*parsedExercise{}

	// evaluate in reverse order - best fit first
	for i := len(regexpSet) - 1; i >= 0; i-- {
		e := regexpSet[i]

		match := e.regexp.FindStringSubmatch(exercise)
		if match == nil {
			continue
		}

		captures := make(map[string]string)

		matchSuccessful := true

		for i, name := range e.regexp.SubexpNames() {
			// Ignore the whole regexp match and unnamed groups
			if i == 0 || name == "" {
				continue
			}

			if e.captureDoesNotContain != nil {
				for _, c := range e.captureDoesNotContain {
					for _, s := range c {
						if strings.Contains(match[i], s) {
							matchSuccessful = false
						}
					}
				}
			}

			assertMissingCapture := e.assertMissingCaptures != nil && utils.SliceContainsString(e.assertMissingCaptures, name)

			if assertMissingCapture && match[i] != "" {
				matchSuccessful = false
			} else if assertMissingCapture {
				continue // ignore capture
			}

			if !matchSuccessful {
				break
			}

			captures[name] = match[i]
		}

		if matchSuccessful {
			allParsed = append(allParsed, &parsedExercise{
				Raw:      exercise,
				Captures: captures,
				Regex:    e.value,
			})
		}
	}

	return allParsed
}
