package parser

import (
	"exercise_parser/utils"
	"fmt"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

func first(p []*ParsedActivity) *ParsedActivity {
	return p[0]
}

// Corrective

func TestCorrectiveActivityExpressions(t *testing.T) {
	t.Run("{Sets:Number}x{Reps:Number}", func(t *testing.T) {
		parsed := resolveAllCorrectiveActivityExpressionsTestUtil("3x35")
		assert.Len(t, parsed, 1)
		assert.Equal(t, first(parsed).CorrectiveCode, CorrectiveCodeMissingExercise)

		expected := map[string]string{"Sets": "3", "Reps": "35"}
		assert.Equal(t, expected, first(parsed).Captures)
	})

	t.Run("{Sets}x{Reps:Number} reps", func(t *testing.T) {
		parsed := resolveAllCorrectiveActivityExpressionsTestUtil("3x35 reps")
		assert.Len(t, parsed, 1)
		assert.Equal(t, parsed[0].CorrectiveCode, CorrectiveCodeMissingExercise)

		expected := map[string]string{"Sets": "3", "Reps": "35"}
		assert.Equal(t, expected, first(parsed).Captures)
	})

	t.Run("{Exercise:String}", func(t *testing.T) {
		parsed := resolveAllCorrectiveActivityExpressionsTestUtil("fast running")
		assert.Len(t, parsed, 1)
		assert.Equal(t, parsed[0].CorrectiveCode, CorrectiveCodeMissingQuantity)

		expected := map[string]string{"Exercise": "fast running"}
		assert.Equal(t, expected, first(parsed).Captures)
	})

	t.Run("{Sets:Number} rounds", func(t *testing.T) {
		parsed := resolveAllCorrectiveActivityExpressionsTestUtil("5 rounds")
		assert.Len(t, parsed, 1)
		assert.Equal(t, parsed[0].CorrectiveCode, CorrectiveCodeMissingExerciseAndReps)

		expected := map[string]string{"Sets": "5"}
		assert.Equal(t, expected, first(parsed).Captures)
	})
}

func resolveAllCorrectiveActivityExpressionsTestUtil(exercise string) []*ParsedActivity {
	regexpSet := correctiveActivityExpressions()

	exercise = strings.Trim(strings.ToLower(exercise), " ")

	allParsed := []*ParsedActivity{}

	// evaluate in reverse order - best fit first
	for i := len(regexpSet) - 1; i >= 0; i-- {
		e := regexpSet[i]

		captures := e.captures(exercise)

		if captures != nil {
			allParsed = append(allParsed, &ParsedActivity{
				Raw:            exercise,
				Captures:       captures,
				Regex:          e.value,
				CorrectiveCode: e.correctiveMessageCode,
			})
		}
	}

	return allParsed
}

// Deep Resolve

func TestDeepResolveActivityExpressions(t *testing.T) {
	// the start of a brave new world
	t.Run("{MaybeExercise:String} {Sets:Number}x{Reps:Number} {MaybeExercise:String}", func(t *testing.T) {
		expected1 := map[string]string{"Exercise": "pull-ups", "Sets": "5", "Reps": "4"}
		expected2 := map[string]string{"Exercise": "conar mcgregor style", "Sets": "5", "Reps": "4"}

		parsed := deepResolveActivityExpressionsTestUtil(t, "Pull-ups 5x4 conar mcgregor style")

		assert.Len(t, parsed, 2)
		assert.Equal(t, expected1, parsed[0].Captures)
		assert.Equal(t, expected2, parsed[1].Captures)
	})

	t.Run("{MaybeExercise:String} {Distance} {DistanceUnits} {MaybeExercise:String}", func(t *testing.T) {
		expected1 := map[string]string{"Exercise": "ran", "Distance": "5", "DistanceUnits": "miles"}
		expected2 := map[string]string{"Exercise": "today", "Distance": "5", "DistanceUnits": "miles"}

		parsed := deepResolveActivityExpressionsTestUtil(t, "ran 5 miles today")

		assert.Len(t, parsed, 2)
		assert.Equal(t, expected1, parsed[0].Captures)
		assert.Equal(t, expected2, parsed[1].Captures)
	})
}

func deepResolveActivityExpressionsTestUtil(t *testing.T, exercise string) []*ParsedActivity {
	expressions := activityExpressions()

	parsedExercises := deepResolveActivityExpressions(exercise, expressions)

	return parsedExercises
}

// Activity Expressions

func TestStrengthActivityFullMatch(t *testing.T) {
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
	slowFastPushUps1 := map[string]string{"Exercise": "slow/fast push-ups", "Sets": "10", "Reps": "3"}

	for _, d := range delimiter {
		t.Run("{Reps:Number} (Delimiter) {Exercise:String}, left wnd right", func(t *testing.T) {
			expected := map[string]string{"Exercise": "walking lunges, left wnd right", "Reps": "12"}
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("12%swalking lunges, left wnd right", d))
			assert.Len(t, parsed, 1)
			assert.Equal(t, expected, parsed[0].Captures)
		})

		t.Run("{Reps:Number} (Delimiter) {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("50%skettlebell swings", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, kettlebellSwings1, parsed[0].Captures)
		})

		t.Run("{Reps:Number}-{Reps:Number} (Delimiter) {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("25-50%skettlebell swings", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, kettlebellSwings2, parsed[0].Captures)
		})

		t.Run("{Reps:Number} (Delimiter) {Exercise:String} (Delimiter) {Weight}", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("12%skettlebell swings%s25lbs", d, d))
			assert.Equal(t, parsed[0].Captures, kettlebellSwings3)
		})

		t.Run("{Reps:Number}-{Reps:Number} (Delimiter) {Exercise:String} (Delimiter) {Weight}", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("10-12%skettlebell swings%s25lbs", d, d))
			assert.Equal(t, parsed[0].Captures, kettlebellSwings4)
		})

		for _, d2 := range delimiter {
			t.Run("{Reps:Number} (Delimiter) {Exercise:String} (Delimiter) {Sets:Number} sets", func(t *testing.T) {
				parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("20%ssquat jumps%s5 sets", d, d2))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, squatJumps1, parsed[0].Captures)
			})
		}
	}

	t.Run("{Sets:Number} {Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3 3 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} {Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3 3 of tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3x3 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} x {Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3 x 3 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3x3 of tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} x {Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3 x 3 of tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} by {Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3 by 3 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} by {Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3 by 3 of tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} by {Reps:Number} sets of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3 by 3 sets of tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} sets of {Reps:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3 sets of 3 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} sets of {Reps:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3 sets of 3 of tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:Number} sets of {Reps:Number} reps {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3 sets of 3 reps tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Sets:number} sets of {Reps:Number} reps of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3 sets of 3 reps of tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	t.Run("{Exericse:String} {Sets:Number} {Reps:Number}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("tricep curls 3 3")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls1, parsed[0].Captures)
	})

	for _, d := range delimiter {
		t.Run("{Exericse:String} (Delimiter) {Sets:Number} {Reps:Number}", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("tricep curls%s3 3", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls1, parsed[0].Captures)
		})

		t.Run("{Exericse:String} (Delimiter) {Sets:Number}x{Reps:Number}", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("tricep curls%s3x3", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls1, parsed[0].Captures)
		})

		t.Run("{Exericse:String} (Delimiter) {Sets:Number}x{Reps:Number}", func(t *testing.T) {
			// this one tests special characters ARE allows: "/" and "-"
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("slow/fast push-ups%s10x3", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, slowFastPushUps1, parsed[0].Captures)
		})

		t.Run("{Exercise:String} (Delimiter) {Sets:Number} by {Reps:Number}", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("tricep curls%s3 by 3", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls1, parsed[0].Captures)
		})

		t.Run("{Exercise:String} (Delimiter) {Sets:Number} sets {Reps:Number} reps", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("tricep curls%s3 sets 3 reps", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls1, parsed[0].Captures)
		})

		t.Run("{Exercise:String} (Delimiter) {Sets:Number} sets of {Reps:Number}", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("tricep curls%s3 sets of 3", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls1, parsed[0].Captures)
		})

		t.Run("{Exercise:String} (Delimiter) {Sets:Number}, sets of {Reps:Number} reps", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("tricep curls%s3 sets of 3 reps", d))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls1, parsed[0].Captures)
		})

		for _, u := range units {
			weightedPullups1 := map[string]string{"Exercise": "weighted pull-ups", "Weight": "25", "WeightUnits": u, "Sets": "2", "Reps": "8"}
			t.Run("{Exercise:String} (Delimiter) {Weight:Number}{WeightUnits} (Delimiter) {Sets:Number}x{Reps:Number}", func(t *testing.T) {
				parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("Weighted pull-ups%s25%s%s2x8", d, u, d))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, weightedPullups1, parsed[0].Captures)
			})

			t.Run("{Exercise:String} (Delimiter) {Weight:Number}{WeightUnits} (Delimiter) {Sets:Number}x{Reps:Number}", func(t *testing.T) {
				parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("Weighted pull-ups%s25%sdumbbell%s2x8", d, u, d))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, weightedPullups1, parsed[0].Captures)
			})

			t.Run("{Exercise:String} (Delimiter) {Weight:Number}{WeightUnits} (Delimiter) {Sets:Number}x{Reps:Number}x{IgnoredWeight:Number}", func(t *testing.T) {
				expected := map[string]string{"Exercise": "weighted pull-ups", "Weight": "25", "WeightUnits": u, "Sets": "2", "Reps": "8"}
				parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("Weighted pull-ups%s25%sdumbbell%s2x8x300", d, u, d)) // 300 should be ignored
				assert.Len(t, parsed, 1)
				assert.Equal(t, expected, parsed[0].Captures)
			})
		}

		jumpRope1 := map[string]string{"Exercise": "jumping rope", "Reps": "200"}
		for _, d := range delimiter {
			t.Run("{Exercise:String} (Delimiter) {Reps:Number}", func(t *testing.T) {
				parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("Jumping rope%s200", d))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, jumpRope1, parsed[0].Captures)
			})

			t.Run("{Exercise:String} (Delimiter) {Reps:Number} reps", func(t *testing.T) {
				expected := map[string]string{"Exercise": "tricep curls", "Reps": "30"}
				parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("tricep curls%s30reps", d))
				assert.Len(t, parsed, 1)
				assert.Equal(t, expected, parsed[0].Captures)
			})
		}
	}

	tricepCurls2 := map[string]string{"Exercise": "tricep curls", "Sets": "3", "Reps": "3", "Weight": "25", "WeightUnits": ""}

	t.Run("{Sets:Number} {Reps:Number} {Weight:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3 3 25 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls2, parsed[0].Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number}x{Weight:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3x3x25 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls2, parsed[0].Captures)
	})

	t.Run("{Sets:Number} x {Reps:Number} x {Weight:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3 x 3 x 25 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls2, parsed[0].Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number}x{Weight:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3x3x25 of tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls2, parsed[0].Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number} at {Weight:Number} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3x3 at 25 tricep curls")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, tricepCurls2, parsed[0].Captures)
	})

	t.Run("{Sets:Number}x{Reps:Number} at {Weight:Number} of {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("3x3 at 25 of tricep curls")
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
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("3 3 25%s tricep curls", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls3, parsed[0].Captures)
		})

		t.Run("{Sets:Number} {Reps:Number} {Weight:Number} {WeightUnits} {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("3 3 25 %s tricep curls", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls3, parsed[0].Captures)
		})

		t.Run("{Sets:Number}x{Reps:Number}x{Weight:Number}{WeightUnits} {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("3x3x25%s tricep curls", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls3, parsed[0].Captures)
		})

		t.Run("{Sets:Number}x{Reps:Number}x{Weight:Number} {WeightUnits} {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("3x3x25 %s tricep curls", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls3, parsed[0].Captures)
		})

		t.Run("{Sets:Number}x{Reps:Number}x{Weight:Number}{WeightUnits} of {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("3x3x25%s of tricep curls", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls3, parsed[0].Captures)
		})

		t.Run("{Sets:Number}x{Reps:Number} at {Weight:Number}{WeightUnits} {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("3x3 at 25%s tricep curls", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls3, parsed[0].Captures)
		})

		t.Run("{Sets:Number}x{Reps:Number} at {Weight:Number}{WeightUnits} of {Exercise:String}", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("3x3 at 25%s of tricep curls", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls3, parsed[0].Captures)
		})

		bilateralRaise1 := map[string]string{"Exercise": "bilateral raise", "Reps": "3", "Weight": "145", "WeightUnits": u}

		t.Run("{Exercise:String} {Reps:Number}x{Weight:Number}{WeightUnits}", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("Bilateral raise 3x145%s", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, bilateralRaise1, parsed[0].Captures)
		})

		t.Run("{Exercise:String} {Reps:Number} reps {Weight:Number}{WeightUnits}", func(t *testing.T) {
			expected := map[string]string{"Exercise": "kettle bell swing", "Reps": "30", "Weight": "40", "WeightUnits": u}
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("Kettle bell Swing 30 reps 40%s", u))
			assert.Len(t, parsed, 1)
			assert.Equal(t, expected, first(parsed).Captures)
		})

		t.Run("{Exercise:String} {Sets:Number}x{Reps:Number}x{Weight:Number}{WeightUnits}", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("tricep curls 3x3x25 %s", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls3, parsed[0].Captures)
		})

		t.Run("{Exercise:String} {Sets:Number}x{Reps:Number}x{Weight:Number} {WeightUnits}", func(t *testing.T) {
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("tricep curls 3x3x25 %s", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, tricepCurls3, parsed[0].Captures)
		})

		for _, d := range delimiter {
			t.Run("{Sets:Number}x{Reps:Number} {Exercise:String} (Delimiter) {Weight:Number}{WeightUnits}", func(t *testing.T) {
				parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("3x3 tricep curls%s25%s", d, u))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, tricepCurls3, parsed[0].Captures)
			})

			t.Run("{Weight:Number}{WeightUnits} (Delimiter) {Exercise:String} {Sets:Number}x{Reps:Number}", func(t *testing.T) {
				parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("25%s%stricep curls 3x3", u, d))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, tricepCurls3, parsed[0].Captures)
			})

			t.Run("{Exercise:String} {Sets:Number}x{Reps:Number} {Delimiter) {Weight:Number} {WeightUnits}", func(t *testing.T) {
				parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("tricep curls 3x3%s25%s", d, u))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, tricepCurls3, parsed[0].Captures)
			})

			t.Run("{Exercise:String} (Delimiter) {Weight:Number}{WeightUnits} dumbbell (Delimiter) {Sets:Number}x{Reps:Number} (Delimiter) {RestPeriod:Number}{RestPeriodUnits} ", func(t *testing.T) {
				dumbbellBentOverRowWithRest := map[string]string{
					"Exercise":        "dumbbell bent over row",
					"Weight":          "36",
					"WeightUnits":     u,
					"Sets":            "3",
					"Reps":            "15",
					"RestPeriod":      "2-3",
					"RestPeriodUnits": "min",
				}

				parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("Dumbbell Bent over row%s36%s dumbbell%s3x15%s2-3 min rest", d, u, d, d))

				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, dumbbellBentOverRowWithRest, parsed[0].Captures)
			})
		}
	}
}

func TestAerobicActivityFullMatch(t *testing.T) {
	delimiter := []string{
		"-", "- ", " -", " - ",
		",", ", ", " ,", " , ",
		" ", "  ",
	}

	distanceUnits := []string{
		"ft", "foot", "feet", "mi", "mils", "mile", "miles", "m", "meter", "meters", "kilometer", "kilometers", "km", "k",
	}

	timeUnits := []string{
		"s", "sec", "secs", "seconds", "min", "mins", "minutes", "hr", "hrs", "hour", "hours",
	}

	t.Run("{Exercise:String} {Time}{TimeUnits} {Distance}{DistanceUnits}", func(t *testing.T) {
		expected := map[string]string{"Exercise": "morning walk", "Time": "35", "TimeUnits": "minutes", "Distance": "1.2", "DistanceUnits": "miles"}
		parsed := resolveAllActivityExpressionsTestUtil("Morning walk 35 minutes 1.2 miles")
		assert.Len(t, parsed, 1)
		assert.Equal(t, expected, first(parsed).Captures)
	})

	t.Run("{Exercise:String} for {Time:Number} {TimeUnits}", func(t *testing.T) {
		expected := map[string]string{"Exercise": "ran", "Time": "5", "TimeUnits": "mins"}
		parsed := resolveAllActivityExpressionsTestUtil("ran for 5 mins")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, expected, parsed[0].Captures)
	})

	// varied: time, distance, delimiter
	for _, timeUnit := range timeUnits {
		for _, distUnit := range distanceUnits {
			for _, del := range delimiter {
				t.Run("{Distance:Float} {DistanceUnits} in {Time:mm:ss} (Delimiter) {Exercise:String}", func(t *testing.T) {
					expected := map[string]string{"Exercise": "rowing", "Time": "5:27", "Distance": "1", "DistanceUnits": distUnit}
					parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("1%s in 5:27%srowing", distUnit, del))
					assert.Len(t, parsed, 1)
					assert.Equal(t, expected, parsed[0].Captures)
				})

				t.Run("{Distance:Float} {DistanceUnits} in {Time:Number}{TimeUnits} (Delimiter) {Exercise:String}", func(t *testing.T) {
					expected := map[string]string{"Exercise": "rowing", "Time": "5", "TimeUnits": timeUnit, "Distance": "1", "DistanceUnits": distUnit}
					parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("1%s in 5%s%srowing", distUnit, timeUnit, del))
					assert.Len(t, parsed, 1)
					assert.Equal(t, expected, parsed[0].Captures)
				})

				t.Run("{Distance}{DistanceUnits} (Delimiter) {Exercise:String} (Delimiter} in {Time}{TimeUnits}", func(t *testing.T) {
					expected := map[string]string{"Exercise": "run", "Distance": "30", "DistanceUnits": distUnit, "Time": "3", "TimeUnits": timeUnit}
					parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("30 %s %s run in 3 %s", distUnit, del, timeUnit))
					assert.Len(t, parsed, 1)
					assert.Equal(t, expected, first(parsed).Captures)
				})

				t.Run("{Distance}{DistanceUnits} (Delimiter) {Exercise:String} (Delimiter} in {Time}{TimeUnits}", func(t *testing.T) {
					expected := map[string]string{"Exercise": "run", "Distance": "30", "DistanceUnits": distUnit, "Time": "3", "TimeUnits": timeUnit}
					parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("30 %s run %s 3 %s", distUnit, del, timeUnit))
					fmt.Println(fmt.Sprintf("30 %s run %s 3 %s", distUnit, del, timeUnit))
					assert.Len(t, parsed, 1)
					assert.Equal(t, expected, first(parsed).Captures)
				})
			}
		}
	}

	for _, timeUnit := range timeUnits {
		for _, d := range delimiter {
			t.Run("{Exercise:String} (Delimiter) {Time:Number} {TimeUnits}", func(t *testing.T) {
				expected := map[string]string{"Exercise": "ran", "Time": "5", "TimeUnits": timeUnit}
				parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("ran%s5 %s", d, timeUnit))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, expected, parsed[0].Captures)
			})

			t.Run("{Time:Number}{TimeUnits} (Delimiter) {Exercise:String} (Delimiter) level {Level:Number}", func(t *testing.T) {
				expected := map[string]string{
					"Exercise":  "stairmaster",
					"Level":     "7",
					"Time":      "10",
					"TimeUnits": timeUnit,
				}
				parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("10%s%sstairmaster%slevel 7", timeUnit, d, d))

				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, expected, parsed[0].Captures)
			})

			t.Run("{Time:Number}-{Time:Number}{TimeUnits} (Delimiter) {Exercise:String} (Delimiter) level {Level:Number}-{Level:Number}", func(t *testing.T) {
				expected := map[string]string{
					"Exercise":  "stairmaster",
					"Level":     "7-9",
					"Time":      "10-15",
					"TimeUnits": timeUnit,
				}
				parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("10-15%s%sstairmaster%slevel 7-9", timeUnit, d, d))

				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, expected, parsed[0].Captures)
			})
		}
	}

	t.Run("{Distance:Float} {Exercise:String}", func(t *testing.T) {
		parsed := resolveAllActivityExpressionsTestUtil("0.5 walk")
		assert.Equal(t, len(parsed), 1)
		assert.Equal(t, parsed[0].Captures, map[string]string{"Exercise": "walk", "Distance": "0.5"})
	})

	for _, u := range distanceUnits {
		t.Run("{Exercise:String} {Distance:Number} {DistanceUnits}", func(t *testing.T) {
			expected := map[string]string{"Exercise": "running", "Distance": "1.55", "DistanceUnits": u}
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("running 1.55 %s", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, expected, parsed[0].Captures)
		})

		t.Run("{Exercise:String} {Distance:Number}{DistanceUnits}", func(t *testing.T) {
			expected := map[string]string{"Exercise": "running", "Distance": "1.55", "DistanceUnits": u}
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("running 1.55%s", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, expected, parsed[0].Captures)
		})

		t.Run("{Exercise:String}, {Distance:Number}{DistanceUnits}", func(t *testing.T) {
			expected := map[string]string{"Exercise": "running", "Distance": "1.55", "DistanceUnits": u}
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("running, 1.55%s", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, expected, parsed[0].Captures)
		})

		t.Run("{Exercise:String} for {Distance:Number} {DistanceUnits}", func(t *testing.T) {
			expected := map[string]string{"Exercise": "running", "Distance": "1.55", "DistanceUnits": u}
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("running for 1.55 %s", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, expected, parsed[0].Captures)
		})

		t.Run("{Exericse:String} for {Distance:Number}{DistanceUnits}", func(t *testing.T) {
			expected := map[string]string{"Exercise": "running", "Distance": "1.55", "DistanceUnits": u}
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("running for 1.55 %s", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, expected, parsed[0].Captures)
		})

		t.Run("{Distance:Float} {DistanceUnits} of {Exercise:String}", func(t *testing.T) {
			expected := map[string]string{"Exercise": "running", "Distance": "1.55", "DistanceUnits": u}
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("1.55 %s running", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, expected, parsed[0].Captures)
		})

		t.Run("{Distance:Float} {DistanceUnits}, of {Exercise:String}", func(t *testing.T) {
			expected := map[string]string{"Exercise": "running", "Distance": "1.55", "DistanceUnits": u}
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("1.55 %s, running", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, expected, parsed[0].Captures)
		})

		t.Run("{Distance:Float} {DistanceUnits} of {Exercise:String}", func(t *testing.T) {
			expected := map[string]string{"Exercise": "running", "Distance": "1.55", "DistanceUnits": u}
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("1.55 %s of running", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, expected, parsed[0].Captures)
		})

		t.Run("{Exercise:String} {Distance:Float} {DistanceUnits} in {Time:Number} {TimeUnits}", func(t *testing.T) {
			expected := map[string]string{"Exercise": "ran", "Distance": "5", "DistanceUnits": u, "Time": "10", "TimeUnits": "minutes"}
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("Ran 5 %s in 10 minutes", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, expected, parsed[0].Captures)
		})

		t.Run("{Exercise:String} {Distance:Float} {DistanceUnits} in {Time:Number} {TimeUnits}", func(t *testing.T) {
			expected := map[string]string{"Exercise": "ran", "Distance": "0.5", "DistanceUnits": u, "Time": "10", "TimeUnits": "minutes"}
			parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("Ran 0.5 %s in 10 minutes", u))
			assert.Equal(t, len(parsed), 1)
			assert.Equal(t, expected, parsed[0].Captures)
		})

		for _, d := range delimiter {
			t.Run("{Exercise:String} {Distance:Float} {DistanceUnits} (Delimiter) {Time:Number} {TimeUnits}", func(t *testing.T) {
				expected := map[string]string{"Exercise": "ran", "Distance": "5", "DistanceUnits": u, "Time": "10", "TimeUnits": "minutes"}
				parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("Ran 5 %s%s10 minutes", u, d))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, expected, parsed[0].Captures)
			})

			t.Run("{Exercise:String} {Distance:Float} {DistanceUnits} (Delimiter) {Time:Number} {TimeUnits}", func(t *testing.T) {
				expected := map[string]string{"Exercise": "ran", "Distance": "0.5", "DistanceUnits": u, "Time": "10", "TimeUnits": "minutes"}
				parsed := resolveAllActivityExpressionsTestUtil(fmt.Sprintf("Ran 0.5 %s%s10 minutes", u, d))
				assert.Equal(t, len(parsed), 1)
				assert.Equal(t, expected, parsed[0].Captures)
			})
		}
	}
}

// TODO: this function is dangerous - we should use resolveExpression
// reason for it is that we return ALL matches against ALL regex patterns - the one in used impl currently only returns the first match
func resolveAllActivityExpressionsTestUtil(exercise string) []*ParsedActivity {
	regexpSet := activityExpressions()

	exercise = strings.Trim(strings.ToLower(exercise), " ")

	allParsed := []*ParsedActivity{}

	// evaluate in reverse order - best fit first
	for i := len(regexpSet) - 1; i >= 0; i-- {
		e := regexpSet[i]

		captures := e.captures(exercise)

		if captures != nil {
			allParsed = append(allParsed, &ParsedActivity{
				Raw:      exercise,
				Captures: captures,
				Regex:    e.value,
			})
		}
	}

	return allParsed
}

// Exercise Expressions

func TestParserResolveExercise(t *testing.T) {
	// TODO: how to better deal with resolving these paths ???

	v, err := utils.ConfigureViper(utils.GetAbsolutePath("conf/dev.toml"))
	if err != nil {
		t.Log(err.Error())
		t.FailNow()
	}

	if err := Init(v); err != nil {
		t.Log(err.Error())
		t.FailNow()
	}

	t.Run("{Exercise1:String} with {Exercise2:String}", func(t *testing.T) {
		exercises, err := Get().ResolveExercise("pushups with mountain climbers")
		assert.NoError(t, err)
		assert.Equal(t, []string{"pushups", "mountain climbers"}, exercises)
	})
}
