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
	value            string
	regexp           *regexp.Regexp
	notMatchCaptures []string
}

func newExpression(value string, notMatchCaptures []string) *expression {
	return &expression{
		value,
		regexp.MustCompile(value),
		notMatchCaptures,
	}
}

func weightedExerciseExpressions() []*expression {
	// increasing specificity is in descending order

	expressions := []*expression{
		newExpression(`^(?P<Reps>\d+)\s*(?P<DontMatchUnits>kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds|mi|mile|miles|m|meter|meters|kilometer|kilometers|km)?\s*(?:,|-|\s)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, []string{"DontMatchUnits"}),                                     // {Reps:Number} (Delimiter) {Exercise:String}
		newExpression(`^(?P<Reps>\d+)\s*(?P<DontMatchUnits>kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds|mi|mile|miles|m|meter|meters|kilometer|kilometers|km)?\s*(?:,|-|\s)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*sets$`, []string{"DontMatchUnits"}), // {Reps:Number} (Delimiter) {Exercise:String} (Delimiter) {Sets:Number} sets

		newExpression(`^(?P<Sets>\d+)\s+(?P<Reps>\d+)\s+(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),                                       // {Sets:Number} {Reps:Number} {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s+(?P<Reps>\d+)\s*(?:of)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),                              // {Sets:Number} {Reps:Number} of {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s+(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),                               // {Sets:Number}x{Reps:Number} {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s*(?:of)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),                      // {Sets:Number}x{Reps:Number} of {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:by)\s*(?P<Reps>\d+)\s+(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),                              // {Sets:Number} by {Reps:Number} {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:by)\s*(?P<Reps>\d+)\s*(?:of)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),                     // {Sets:Number} by {Reps:Number} of {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:by)\s*(?P<Reps>\d+)\s*(?:sets)\s+(?:of)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),          // {Sets:Number} by {Reps:Number} sets of {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:sets)\s*(?:of)\s*(?P<Reps>\d+)\s+(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),                   // {Sets:Number} sets of {Reps:Number} {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:sets)\s*(?:of)\s*(?P<Reps>\d+)\s*(?:of)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),          // {Sets:Number} sets of {Reps:Number} of {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:sets)\s*(?:of)\s*(?P<Reps>\d+)\s*(reps)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),          // {Sets:Number} sets of {Reps:Number} reps {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:sets)\s*(?:of)\s*(?P<Reps>\d+)\s*(reps)\s*(?:of)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil), // {Sets:number} sets of {Reps:Number} reps of {Exercise:String}

		newExpression(`^(?P<Sets>\d+)\s+(?P<Reps>\d+)\s+(?P<Weight>\d+)\s+(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),                           // {Sets:Number} {Reps:Number} {Weight:Number} {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s*(?:x)\s*(?P<Weight>\d+)\s+(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),           // {Sets:Number}x{Reps:Number}x{Weight:Number} {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s*(?:x)\s*(?P<Weight>\d+)\s*(?:of)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),  // {Sets:Number}x{Reps:Number}x{Weight:Number} of {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s*(?:at)\s*(?P<Weight>\d+)\s+(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),          // {Sets:Number}x{Reps:Number} at {Weight:Number} {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s*(?:at)\s*(?P<Weight>\d+)\s*(?:of)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil), // {Sets:Number}x{Reps:Number} at {Weight:Number} of {Exercise:String}

		newExpression(`^(?P<Sets>\d+)\s+(?P<Reps>\d+)\s+(?P<Weight>\d+)\s*(?P<Units>kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)\s+(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),                           // {Sets:Number} {Reps:Number} {Weight:Number}{Units} {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s*(?:x)\s*(?P<Weight>\d+)\s*(?P<Units>kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)\s+(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),           // {Sets:Number}x{Reps:Number}x{Weight:Number}{Units} {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s*(?:x)\s*(?P<Weight>\d+)\s*(?P<Units>kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)\s+(?:of)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),  // {Sets:Number}x{Reps:Number}x{Weight:Number}{Units} of {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s*(?:at)\s*(?P<Weight>\d+)\s*(?P<Units>kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)\s+(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil),          // {Sets:Number}x{Reps:Number} at {Weight:Number}{Units} {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s*(?:at)\s*(?P<Weight>\d+)\s*(?P<Units>kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)\s+(?:of)\s*(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z]$)`, nil), // {Sets:Number}x{Reps:Number} at {Weight:Number}{Units} of {Exercise:String}

		newExpression(`^(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s+(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Weight>\d+)\s*(?P<Units>(kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)$)`, nil), // {Sets:Number}x{Reps:Number} {Exercise:String} (Delimiter) {Weight:Number}{Units}

		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Reps>\d+$)`, nil), // {Exercise:String} (Delimiter) {Reps:Number}

		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s+(?P<Reps>\d+$)`, nil),                                // {Exercise:String} (Delimiter) {Sets:Number} {Reps:Number}
		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+$)`, nil),                        // {Exercise:String} (Delimiter) {Sets:Number}x{Reps:Number}
		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*(?:by)\s*(?P<Reps>\d+$)`, nil),                       // {Exercise:String} (Delimiter) {Sets:Number} by {Reps:Number}
		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*(?:sets)\s*(?P<Reps>\d+$)`, nil),                     // {Exercise:String} (Delimiter) {Sets:Number} sets {Reps:Number}
		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*(?:sets)\s*(?P<Reps>\d+)\s*(?:reps$)`, nil),          // {Exercise:String} (Delimiter) {Sets:Number} sets {Reps:Number} reps
		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*(?:sets)\s*(?:of)\s*(?P<Reps>\d+$)`, nil),            // {Exercise:String} (Delimiter) {Sets:Number} sets of {Reps:Number} reps
		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*(?:sets)\s*(?:of)\s*(?P<Reps>\d+)\s*(?:reps$)`, nil), // {Exercise:String} (Delimiter) {Sets:Number} sets of {Reps:Number} reps

		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s*(?:,|-|\s)\s*(?P<Weight>\d+)\s*(?P<Units>(kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)$)`, nil), // {Exercise:String} (Delimiter) {Sets:Number}x{Reps:Number} (Delimiter) {Weight:Number}{Units}

		newExpression(`^(?P<Exercise>[a-zA-Z\-\s]+[a-zA-Z])\s*(?:,|-|\s)\s*(?P<Weight>\d+)\s*(?P<Units>kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)\s*(?:,|-|\s)\s*(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+$)`, nil), // {Exercise:String} (Delimiter) {Weight:Number}{Units} (Delimiter) {Sets:Number}x{Reps:Number}
	}

	return expressions
}

func distanceExerciseExpressions() []*expression {
	// increasing specificity is in descending order

	expressions := []*expression{
		newExpression(`^(?P<Exercise>[a-zA-Z\s]+[a-zA-Z])(?:(?:\s+)|(?:\s*,\s*))(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<Units>(mi|mile|miles|m|meter|meters|kilometer|kilometers|km)$)`, nil), // {Exercise:String} {Distance:Number} {Units:String}
		newExpression(`^(?P<Exercise>[a-zA-Z\s]+[a-zA-Z])\s+(?:for)\s+(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<Units>(mi|mile|miles|m|meter|meters|kilometer|kilometers|km)$)`, nil),           // {Exercise:String} for {Distance:Number} {Units:String}

		newExpression(`^(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<Units>mi|mile|miles|m|meter|meters|kilometer|kilometers|km)(?:(?:\s+)|(?:\s*,\s*))(?P<Exercise>[a-zA-Z\s]+[a-zA-Z]$)`, nil), // {Distance:Float} {Units:String} {Exercise:String}
		newExpression(`^(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<Units>mi|mile|miles|m|meter|meters|kilometer|kilometers|km)\s+of\s+(?P<Exercise>[a-zA-Z\s]+[a-zA-Z]$)`, nil),                // {Distance:Float} {Units:String} of {Exercise:String}

		newExpression(`^(?P<Exercise>[a-zA-Z\s]+[a-zA-Z])\s+(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<Units>mi|mile|miles|m|meter|meters|kilometer|kilometers|km)\s+in\s+(?P<Time>\d+)\s*(?P<TimeUnits>(sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours)$)`, nil),         // {Exercise:String} {Distance:Number} {Units:String} in {Time:Number}{TimeUnits}
		newExpression(`^(?P<Exercise>[a-zA-Z\s]+[a-zA-Z])\s+(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<Units>mi|mile|miles|m|meter|meters|kilometer|kilometers|km)\s*(?:,|-|\s)\s*(?P<Time>\d+)\s*(?P<TimeUnits>(sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours)$)`, nil), // {Exercise:String} {Distance:Number} {Units:String} (Delimiter) {Time:String}{TimeUnits}
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

			isNotMatchCapture := e.notMatchCaptures != nil && utils.SliceContainsString(e.notMatchCaptures, name)

			if isNotMatchCapture && match[i] != "" {
				matchSuccessful = false
				break
			} else if isNotMatchCapture {
				continue // ignore capture
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
		utils.PrettyPrint(distanceExercise)
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
