package server

import (
	"fmt"
	"regexp"
	"strings"
)

// Result holds the parsed captures from resolve
type Result struct {
	Type     string
	Captures map[string]string
}

type parsedExercise struct {
	Raw      string
	Captures map[string]string
}

func weightedExerciseExpressions() []string {
	// increasing specificity is in descending order

	expressions := []string{
		`^(?P<Sets>\d+)\s+(?P<Reps>\d+)\s+(?P<Exercise>[a-zA-Z\s]+)`,                                       // {Sets:Number} {Reps:Number} {Exercise:String}
		`^(?P<Sets>\d+)\s+(?P<Reps>\d+)\s*(?:of)\s*(?P<Exercise>[a-zA-Z\s]+)`,                              // {Sets:Number} {Reps:Number} of {Exercise:String}
		`^(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s+(?P<Exercise>[a-zA-Z\s]+)`,                               // {Sets:Number}x{Reps:Number} {Exercise:String}
		`^(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s*(?:of)\s*(?P<Exercise>[a-zA-Z\s]+)`,                      // {Sets:Number}x{Reps:Number} of {Exercise:String}
		`^(?P<Sets>\d+)\s*(?:by)\s*(?P<Reps>\d+)\s+(?P<Exercise>[a-zA-Z\s]+)`,                              // {Sets:Number} by {Reps:Number} {Exercise:String}
		`^(?P<Sets>\d+)\s*(?:by)\s*(?P<Reps>\d+)\s*(?:of)\s*(?P<Exercise>[a-zA-Z\s]+)`,                     // {Sets:Number} by {Reps:Number} of {Exercise:String}
		`^(?P<Sets>\d+)\s*(?:by)\s*(?P<Reps>\d+)\s*(?:sets)\s+(?:of)\s*(?P<Exercise>[a-zA-Z\s]+)`,          // {Sets:Number} by {Reps:Number} sets of {Exercise:String}
		`^(?P<Sets>\d+)\s*(?:sets)\s*(?:of)\s*(?P<Reps>\d+)\s+(?P<Exercise>[a-zA-Z\s]+)`,                   // {Sets:Number} sets of {Reps:Number} {Exercise:String}
		`^(?P<Sets>\d+)\s*(?:sets)\s*(?:of)\s*(?P<Reps>\d+)\s*(?:of)\s*(?P<Exercise>[a-zA-Z\s]+)`,          // {Sets:Number} sets of {Reps:Number} of {Exercise:String}
		`^(?P<Sets>\d+)\s*(?:sets)\s*(?:of)\s*(?P<Reps>\d+)\s*(reps)\s*(?P<Exercise>[a-zA-Z\s]+)`,          // {Sets:Number} sets of {Reps:Number} reps {Exercise:String}
		`^(?P<Sets>\d+)\s*(?:sets)\s*(?:of)\s*(?P<Reps>\d+)\s*(reps)\s*(?:of)\s*(?P<Exercise>[a-zA-Z\s]+)`, // {Sets:number} sets of {Reps:Number} reps of? {Exercise:String}

		`^(?P<Exercise>[a-zA-Z\s]+)(?:(?:\s+)|(?:\s*,\s*))(?P<Sets>\d+)\s+(?P<Reps>\d+)`,                                // {Exericse:String} {Sets:Number} {Reps:Number}
		`^(?P<Exercise>[a-zA-Z\s]+)(?:(?:\s+)|(?:\s*,\s*))(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)`,                        // {Exericse:String} {Sets:Number}x{Reps:Number}
		`^(?P<Exercise>[a-zA-Z\s]+)(?:(?:\s+)|(?:\s*,\s*))(?P<Sets>\d+)\s*(?:by)\s*(?P<Reps>\d+)`,                       // {Exercise:String} {Sets:Number} by {Reps:Number}
		`^(?P<Exercise>[a-zA-Z\s]+)(?:(?:\s+)|(?:\s*,\s*))(?P<Sets>\d+)\s*(?:sets)\s*(?P<Reps>\d+)`,                     // {Exercise:String} {Sets:Number} sets {Reps:Number}
		`^(?P<Exercise>[a-zA-Z\s]+)(?:(?:\s+)|(?:\s*,\s*))(?P<Sets>\d+)\s*(?:sets)\s*(?P<Reps>\d+)\s*(?:reps)`,          // {Exercise:String} {Sets:Number} sets {Reps:Number} reps
		`^(?P<Exercise>[a-zA-Z\s]+)(?:(?:\s+)|(?:\s*,\s*))(?P<Sets>\d+)\s*(?:sets)\s*(?:of)\s*(?P<Reps>\d+)`,            // {Exercise:String} {Sets:Number} sets of {Reps:Number} reps
		`^(?P<Exercise>[a-zA-Z\s]+)(?:(?:\s+)|(?:\s*,\s*))(?P<Sets>\d+)\s*(?:sets)\s*(?:of)\s*(?P<Reps>\d+)\s*(?:reps)`, // {Exercise:String} {Sets:Number} sets of {Reps:Number} reps
	}

	return expressions
}

func distanceExerciseExpressions() []string {
	// increasing specificity is in descending order

	// TODO: The {Units} capture should be more specific. Eg: (?P<Units>miles|mile|kilometers|km)

	expressions := []string{
		`^(?P<Exercise>[a-zA-Z\s]+)(?:(?:\s+)|(?:\s*,\s*))(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<Units>[a-zA-Z\s]+)`,      // {Exercise:String} {Distance:Number} {Units:String}
		`^(?P<Exercise>[a-zA-Z\s]+)\s+(?:for)\s+(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<Units>[a-zA-Z\s]+)`,                // {Exercise:String} for {Distance:Number} {Units:String}
		`^(?P<Exercise>[a-zA-Z\s]+)\s+(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<Units>[a-zA-Z\s]+)\s+in\s+(?P<Time>[\w\s]+)`, // {Exercise:String} {Distance:Number} {Units:String} in {Time:String}
		`^(?P<Distance>([0-9]*[.])?[0-9]+)\s+(?P<Units>[a-zA-Z\s]+)(?:(?:\s+)|(?:\s*,\s*))(?P<Exercise>[a-zA-Z\s]+)`,      // {Distance:Float} {Units:String} {Exercise:String}
		`^(?P<Distance>([0-9]*[.])?[0-9]+)\s+(?P<Units>[a-zA-Z\s]+)\s+of\s+(?P<Exercise>[a-zA-Z\s]+)`,                     // {Distance:Float} {Units:String} of {Exercise:String}
	}

	return expressions
}

func resolveExpressions(exercise string, regexpSet []string) *parsedExercise {
	exercise = strings.Trim(strings.ToLower(exercise), " ") // basic sanitization

	// TODO: reduce raw string to lemma
	// TODO: convert words to numbers

	regexps := make([]*regexp.Regexp, len(regexpSet), len(regexpSet))

	for i := len(regexpSet) - 1; i >= 0; i-- {
		// we create regexps in reverse order because we want better "fitted" regexps confirmed first
		regexps[len(regexpSet)-i-1] = regexp.MustCompile(regexpSet[i])
	}

	for _, r := range regexps {
		match := r.FindStringSubmatch(exercise)
		if match == nil {
			continue
		}

		captures := make(map[string]string)

		for i, name := range r.SubexpNames() {
			// Ignore the whole regexp match and unnamed groups
			if i == 0 || name == "" {
				continue
			}

			captures[name] = match[i]
		}

		parsed := &parsedExercise{
			Raw:      exercise,
			Captures: captures,
		}

		return parsed
	}

	return &parsedExercise{
		Raw: exercise,
	}
}

// Resolve returns the captures
func Resolve(exercise string) (*Result, error) {
	weightedExercise := resolveExpressions(exercise, weightedExerciseExpressions())
	distanceExercise := resolveExpressions(exercise, distanceExerciseExpressions())

	if weightedExercise.Captures != nil && distanceExercise.Captures != nil {
		return nil, fmt.Errorf(
			"multiple matches: %v, %v",
			weightedExercise,
			distanceExercise,
		)
	} else if weightedExercise.Captures != nil {
		return &Result{
			Type:     "weighted",
			Captures: weightedExercise.Captures,
		}, nil
	} else if distanceExercise.Captures != nil {
		return &Result{
			Type:     "distance",
			Captures: distanceExercise.Captures,
		}, nil
	}

	return nil, fmt.Errorf("no match found")
}
