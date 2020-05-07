package parser

import (
	"exercise_parser/utils"
	"fmt"
	"regexp"
	"strings"
	"sync"

	"github.com/spf13/viper"
)

// Result holds the parsed captures from resolve
type Result struct {
	Type     string
	Captures map[string]string
}

type parsedExercise struct {
	Raw      string
	Captures map[string]string
	Regex    string
}

type expression struct {
	value                 string
	regexp                *regexp.Regexp
	assertMissingCaptures []string
	captureDoesNotContain map[string][]string
}

func newExpression(value string, captureDoesNotContain map[string][]string, assertMissingCaptures []string) *expression {
	return &expression{
		value,
		regexp.MustCompile(value),
		assertMissingCaptures,
		captureDoesNotContain,
	}
}

func weightedExerciseExpressions() []*expression {
	// increasing specificity is in descending order

	expressions := []*expression{
		newExpression(`^(?P<Reps>\d+|\d+\-\d+)\s*(?P<NotUnits>sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours|kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds|ft|foot|feet||mi|mile|miles|m|meter|meters|kilometer|kilometers|km)?\s*(?:,|-|\s)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil, []string{"NotUnits"}),                                                                                                     // {Reps:Number}-{Reps:Number} (Delimiter) {Exercise:String}
		newExpression(`^(?P<Reps>\d+|\d+\-\d+)\s*(?P<NotUnits>sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours|kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds|ft|foot|feet||mi|mile|miles|m|meter|meters|kilometer|kilometers|km)?\s*(?:,|-|\s)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Weight>\d+)\s*(?P<WeightUnits>(kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)$)`, nil, []string{"NotUnits"}), // {Reps:Number} (Delimiter) {Exercise:String} - {Weight:Number}{WeightUnits}
		newExpression(`^(?P<Reps>\d+)\s*(?P<NotUnits>sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours|kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds|ft|foot|feet||mi|mile|miles|m|meter|meters|kilometer|kilometers|km)?\s*(?:,|-|\s)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*sets$`, nil, []string{"NotUnits"}),                                                                          // {Reps:Number} (Delimiter) {Exercise:String} (Delimiter) {Sets:Number} sets

		newExpression(`^(?P<Sets>\d+)\s*(?:sets\sof|x|by|\s)\s*(?P<Reps>\d+)\s*(?:sets\sof|reps\sof|sets|reps|of|\s)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil, nil),                                                             // {Sets:Number} (sets of|x|by|space) {Reps:Number} (?:sets of|reps of|sets|reps|of|space) {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:x|\s)\s*(?P<Reps>\d+)\s*(?:x|at|\s)\s*(?P<Weight>\d+)\s*(?P<WeightUnits>kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)?\s*(?:of|\s)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil, nil), // {Sets:Number}x{Reps:Number}x{Weight:Number}{WeightUnits} of {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s+(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Weight>\d+)\s*(?P<WeightUnits>(kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)$)`, nil, nil),                // {Sets:Number}x{Reps:Number} {Exercise:String} (Delimiter) {Weight:Number}{WeightUnits}

		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Reps>\d+$)`, nil, nil), // {Exercise:String} (Delimiter) {Reps:Number}

		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s+(?P<Reps>\d+$)`, nil, nil),                                // {Exercise:String} (Delimiter) {Sets:Number} {Reps:Number}
		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+$)`, nil, nil),                        // {Exercise:String} (Delimiter) {Sets:Number}x{Reps:Number}
		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*(?:by)\s*(?P<Reps>\d+$)`, nil, nil),                       // {Exercise:String} (Delimiter) {Sets:Number} by {Reps:Number}
		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*(?:sets)\s*(?P<Reps>\d+$)`, nil, nil),                     // {Exercise:String} (Delimiter) {Sets:Number} sets {Reps:Number}
		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*(?:sets)\s*(?P<Reps>\d+)\s*(?:reps$)`, nil, nil),          // {Exercise:String} (Delimiter) {Sets:Number} sets {Reps:Number} reps
		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*(?:sets)\s*(?:of)\s*(?P<Reps>\d+$)`, nil, nil),            // {Exercise:String} (Delimiter) {Sets:Number} sets of {Reps:Number}
		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*(?:sets)\s*(?:of)\s*(?P<Reps>\d+)\s*(?:reps$)`, nil, nil), // {Exercise:String} (Delimiter) {Sets:Number} sets of {Reps:Number} reps

		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Reps>\d+)\s*(?:x)\s*(?P<Weight>\d+)\s*(?P<WeightUnits>(kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)$)`, nil, nil),                              // {Exercise:String} (Delimiter) {Sets:Number}x{Weight:Number}{WeightUnits}
		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s*(?:,|-|\s)\s*(?P<Weight>\d+)\s*(?P<WeightUnits>(kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)$)`, nil, nil), // {Exercise:String} (Delimiter) {Sets:Number}x{Reps:Number} (Delimiter) {Weight:Number}{WeightUnits}

		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Weight>\d+)\s*(?P<WeightUnits>kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)\s*(dumbbell|dumbbells|barbel|barbells)?\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+$)`, nil, nil), // {Exercise:String} (Delimiter) {Weight:Number}{WeightUnits} (Delimiter) {Sets:Number}x{Reps:Number}
	}

	return expressions
}

func distanceExerciseExpressions() []*expression {
	// increasing specificity is in descending order

	expressions := []*expression{
		newExpression(`^(?P<Exercise>[a-zA-Z\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<DistanceUnits>(ft|foot|feet|mi|mile|miles|m|meter|meters|kilometer|kilometers|km)$)`, map[string][]string{"Exercise": {"for"}}, nil), // {Exercise:String} (Delimiter) {Distance:Float}{DistanceUnits} :TODO - delimiter test
		newExpression(`^(?P<Exercise>[a-zA-Z\s]+[a-zA-Z])\s+(?:for)\s+(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<DistanceUnits>(ft|foot|feet|mi|mile|miles|m|meter|meters|kilometer|kilometers|km)$)`, nil, nil),                                         // {Exercise:String} for {Distance:Float}{DistanceUnits}

		newExpression(`^(?P<Exercise>[a-zA-Z\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Time>\d+)\s*(?P<TimeUnits>(sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours)$)`, map[string][]string{"Exercise": {"for"}}, nil), // {Exercise:String} (Delimiter) {Time:String}{TimeUnits}
		newExpression(`^(?P<Exercise>[a-zA-Z\s]+[a-zA-Z])\s+(?:for)\s+(?P<Time>\d+)\s*(?P<TimeUnits>(sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours)$)`, nil, nil),                                         // {Exercise:String} for {Time:String}{TimeUnits}

		newExpression(`^(?P<Exercise>[a-zA-Z\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<DistanceUnits>ft|foot|feet|mi|mile|miles|m|meter|meters|kilometer|kilometers|km)\s*(?:,|-|\s)\s*(?:in)?\s*(?P<Time>\d+)\s*(?P<TimeUnits>(sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours)$)`, nil, nil), // {Exercise:String} (Delimiter) {Distance:Float}{DistanceUnits} (Delimiter) {Time:String}{TimeUnits} :TODO - add delimiter ttest

		newExpression(`^(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<DistanceUnits>ft|foot|feet|mi|mile|miles|m|meter|meters|kilometer|kilometers|km)\s*(?:,|-|\s)\s*(?:of)?\s*(?P<Exercise>[a-zA-Z\s]+[a-zA-Z]$)`, nil, nil), // {Distance:Float}{DistanceUnits} (Delimiter) of? {Exercise:String} :TODO - delimiter test
	}

	return expressions
}

func resolveExpressions(exercise string, regexpSet []*expression) *parsedExercise {
	exercise = strings.Trim(strings.ToLower(exercise), " ")

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
			return &parsedExercise{
				Raw:      exercise,
				Captures: captures,
				Regex:    e.value,
			}
		}
	}

	return &parsedExercise{
		Raw: exercise,
	}
}

// Parser allows you to resolve raw exercise strings
type Parser struct {
	lemma                       *lemma
	weightedExerciseExpressions []*expression
	distanceExerciseExpressions []*expression
}

// Resolve returns the captures
func (p *Parser) Resolve(exercise string) (*Result, error) {
	// exercise = p.lemmatize(exercise) // TODO: should we lemmatize?

	// resolve expression

	weightedExercise := resolveExpressions(exercise, p.weightedExerciseExpressions)
	distanceExercise := resolveExpressions(exercise, p.distanceExerciseExpressions)

	if weightedExercise.Captures != nil {
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

func (p *Parser) lemmatize(s string) string {
	tokens := strings.Split(s, " ")
	lemmas := make([]string, len(tokens), len(tokens))
	for i, t := range tokens {
		lemmas[i] = p.lemma.get(t)
	}

	return strings.Join(lemmas, " ")
}

var parser *Parser
var onceParser sync.Once

// Init will initialize global parser object
func Init(v *viper.Viper) error {
	var err error
	onceParser.Do(func() {
		lemma := newLemma()
		err = lemma.readLemmas(v.GetString("resources.dir.lemmas"))

		parser = &Parser{
			lemma:                       lemma,
			weightedExerciseExpressions: weightedExerciseExpressions(),
			distanceExerciseExpressions: distanceExerciseExpressions(),
		}
	})

	return err
}

// Get returns global parser object
func Get() *Parser {
	return parser
}
