package parser

import (
	"exercise_parser/utils"
	"fmt"
	"regexp"
	"strings"
	"sync"

	"github.com/spf13/viper"
)

const (
	ParseTypeFull       = "full"
	ParseTypePartial    = "partial"
	ParseTypeCorrective = "corrective"
)

type ParsedActivity struct {
	Raw            string
	Captures       map[string]string
	Regex          string
	ParseType      string
	CorrectiveCode int
}

type expression struct {
	value                 string
	regexp                *regexp.Regexp
	assertMissingCaptures []string            // make sure we don't have these captures in expression
	captureDoesNotContain map[string][]string // what was this for again???

	correctiveMessage     string
	correctiveMessageCode int // WARNING: do not change these values - the client will use it to show an associated message to the user
}

func (e *expression) captures(strExpressionToParse string) map[string]string {
	match := e.regexp.FindStringSubmatch(strExpressionToParse)
	if match == nil {
		return nil
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

	if !matchSuccessful {
		return nil
	}

	return captures
}

func newExpression(value string, captureDoesNotContain map[string][]string, assertMissingCaptures []string) *expression {
	return &expression{
		value,
		regexp.MustCompile(value),
		assertMissingCaptures,
		captureDoesNotContain,
		"",
		CorrectiveCodeNone,
	}
}

func newCorrectiveExpression(value string, correctiveMessage string, correctiveMessageCode int) *expression {
	return &expression{
		value:                 value,
		regexp:                regexp.MustCompile(value),
		correctiveMessage:     correctiveMessage,
		correctiveMessageCode: correctiveMessageCode,
	}
}

const (
	CorrectiveCodeNone                   = 0
	CorrectiveCodeMissingExercise        = 1
	CorrectiveCodeMissingQuantity        = 2
	CorrectiveCodeMissingExerciseAndReps = 3
)

func DetermineIfHasExerciseFromCorrectiveCode(correctiveCode int) bool {
	if correctiveCode == CorrectiveCodeMissingExercise ||
		correctiveCode == CorrectiveCodeMissingExerciseAndReps {
		return false
	}

	return true
}

func correctiveActivityExpressions() []*expression {
	expressions := []*expression{
		newCorrectiveExpression(`^(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+$)`, "specify an exercise", CorrectiveCodeMissingExercise),        // {Sets:Number}x{Reps:Number}
		newCorrectiveExpression(`^(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s*reps$`, "specify an exercise", CorrectiveCodeMissingExercise), // {Sets:Number}x{Reps:Number} reps
		newCorrectiveExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])$`, "specify quantity", CorrectiveCodeMissingQuantity),          // {Exercise:String}
		newCorrectiveExpression(`^(?P<Sets>\d+)\s+rounds$`, "specify exercise and reps or time", CorrectiveCodeMissingExerciseAndReps),  // {Sets:Number} rounds
	}

	return expressions
}

func activityExpressions() []*expression {
	expressions := []*expression{
		newExpression(`^(?P<Reps>\d+|\d+\-\d+)\s*(?P<NotUnits>s|sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours|kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds|ft|foot|feet|mi|mile|miles|m|meter|meters|kilometer|kilometers|km|k)?\s*(?:,+|-|\s)\s*(?P<Exercise>([a-zA-Z,\/\-\s]+[a-zA-Z])$)`, nil, []string{"NotUnits"}),                                                                                                    // {Reps:Number}-{Reps:Number} (Delimiter) {Exercise:String}
		newExpression(`^(?P<Reps>\d+|\d+\-\d+)\s*(?P<NotUnits>s|sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours|kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds|ft|foot|feet|mi|mile|miles|m|meter|meters|kilometer|kilometers|km|k)?\s*(?:,+|-|\s)\s*(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Weight>\d+)\s*(?P<WeightUnits>(kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)$)`, nil, []string{"NotUnits"}), // {Reps:Number}-{Reps:Number} (Delimiter) {Exercise:String} - {Weight:Number}{WeightUnits}
		newExpression(`^(?P<Reps>\d+)\s*(?P<NotUnits>s|sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours|kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds|ft|foot|feet|mi|mile|miles|m|meter|meters|kilometer|kilometers|km|k)?\s*(?:,+|-|\s)\s*(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Sets>\d+)\s*sets$`, nil, []string{"NotUnits"}),                                                                          // {Reps:Number} (Delimiter) {Exercise:String} (Delimiter) {Sets:Number} sets

		newExpression(`^(?P<Sets>\d+)\s*(?:sets\sof|x|by|\s)\s*(?P<Reps>\d+)\s*(?:sets\sof|reps\sof|sets|reps|of|\s)\s*(?P<Exercise>([a-zA-Z,\/\-\s]+[a-zA-Z])$)`, nil, nil),                                                             // {Sets:Number} (sets of|x|by|space) {Reps:Number} (?:sets of|reps of|sets|reps|of|space) {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:x|\s)\s*(?P<Reps>\d+)\s*(?:x|at|\s)\s*(?P<Weight>\d+)\s*(?P<WeightUnits>kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)?\s*(?:of|\s)\s*(?P<Exercise>([a-zA-Z,\/\-\s]+[a-zA-Z])$)`, nil, nil), // {Sets:Number}x{Reps:Number}x{Weight:Number}{WeightUnits} of {Exercise:String}
		newExpression(`^(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s+(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Weight>\d+)\s*(?P<WeightUnits>(kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)$)`, nil, nil),                 // {Sets:Number}x{Reps:Number} {Exercise:String} (Delimiter) {Weight:Number}{WeightUnits}

		newExpression(`^(?P<Weight>\d+)\s*(?P<WeightUnits>kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)\s*(?:,+|-|\s)\s*(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+$)`, nil, nil), // {Weight:Number}{WeightUnits} (Delimiter) {Exercise:String} {Sets:Number}x{Reps:Number}

		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Reps>\d+$)`, nil, nil),                                                // {Exercise:String} (Delimiter) {Reps:Number}
		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Reps>\d+)\s*reps$`, nil, nil),                                         // {Exercise:String} (Delimiter) {Reps:Number} reps
		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Sets>\d+)\s+(?P<Reps>\d+$)`, nil, nil),                                // {Exercise:String} (Delimiter) {Sets:Number} {Reps:Number}
		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+$)`, nil, nil),                        // {Exercise:String} (Delimiter) {Sets:Number}x{Reps:Number}
		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Sets>\d+)\s*(?:by)\s*(?P<Reps>\d+$)`, nil, nil),                       // {Exercise:String} (Delimiter) {Sets:Number} by {Reps:Number}
		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Sets>\d+)\s*(?:sets)\s*(?P<Reps>\d+$)`, nil, nil),                     // {Exercise:String} (Delimiter) {Sets:Number} sets {Reps:Number}
		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Sets>\d+)\s*(?:sets)\s*(?P<Reps>\d+)\s*(?:reps$)`, nil, nil),          // {Exercise:String} (Delimiter) {Sets:Number} sets {Reps:Number} reps
		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Sets>\d+)\s*(?:sets)\s*(?:of)\s*(?P<Reps>\d+$)`, nil, nil),            // {Exercise:String} (Delimiter) {Sets:Number} sets of {Reps:Number}
		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Sets>\d+)\s*(?:sets)\s*(?:of)\s*(?P<Reps>\d+)\s*(?:reps$)`, nil, nil), // {Exercise:String} (Delimiter) {Sets:Number} sets of {Reps:Number} reps

		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Reps>\d+)\s*(?:x)\s*(?P<Weight>\d+)\s*(?P<WeightUnits>(kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)$)`, nil, nil),                               // {Exercise:String} (Delimiter) {Sets:Number}x{Weight:Number}{WeightUnits}
		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s*(?:x)\s*(?P<Weight>\d+)\s*(?P<WeightUnits>(kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)$)`, nil, nil),       // {Exercise:String} (Delimiter) {Sets:Number}x{Reps:Number}x{Weight:Number}{WeightUnits}
		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s*(?:,+|-|\s)\s*(?P<Weight>\d+)\s*(?P<WeightUnits>(kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)$)`, nil, nil), // {Exercise:String} (Delimiter) {Sets:Number}x{Reps:Number} (Delimiter) {Weight:Number}{WeightUnits}

		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Weight>\d+)\s*(?P<WeightUnits>kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)\s*(dumbbell|dumbbells|barbel|barbells)?\s*(?:,+|-|\s)\s*(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+$)`, nil, nil),                                                                                                                                // {Exercise:String} (Delimiter) {Weight:Number}{WeightUnits} (Delimiter) {Sets:Number}x{Reps:Number}
		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Weight>\d+)\s*(?P<WeightUnits>kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)\s*(dumbbell|dumbbells|barbel|barbells)?\s*(?:,+|-|\s)\s*(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s*(?:x)\s*(?:\d+$)`, nil, nil),                                                                                                              // {Exercise:String} (Delimiter) {Weight:Number}{WeightUnits} (Delimiter) {Sets:Number}x{Reps:Number}x{IgnoredWeight:Number}
		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Weight>\d+)\s*(?P<WeightUnits>kg|kilos|kilogram|kilograms|lb|lbs|pound|pounds)\s*(dumbbell|dumbbells|barbel|barbells)?\s*(?:,+|-|\s)\s*(?P<Sets>\d+)\s*(?:x)\s*(?P<Reps>\d+)\s*(?:,+|-|\s)\s*(?P<RestPeriod>\d+|\d+\-\d+)\s*(?P<RestPeriodUnits>sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours)\s*rest$`, nil, nil), // {Exercise:String} (Delimiter) {Weight:Number}{WeightUnits} (Delimiter) {Sets:Number}x{Reps:Number} (Delimiter) {RestPeriod:Number} {RestPeriodUnits}

		newExpression(`^(?P<Time>\d+|\d+\-\d+)\s*(?P<TimeUnits>s|sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours)\s*(?:,+|-|\s)\s*(?:of)?\s*(?P<Exercise>([a-zA-Z,\/\-\s]+[a-zA-Z])$)`, nil, nil),                                       // {Time:Number}{TimeUnits} (Delimiter) of? {Exercise}
		newExpression(`^(?P<Time>\d+|\d+\-\d+)\s*(?P<TimeUnits>s|sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours)\s*(?:,+|-|\s)\s*(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*level\s*(?P<Level>(\d+|\d+\-\d+)$)`, nil, nil), // {Time:Number}{TimeUnits} (Delimiter) {Exercise} level {Level:Number}-{Level:Number}

		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<DistanceUnits>(ft|foot|feet|mi|mile|miles|m|meter|meters|kilometer|kilometers|km|k)$)`, map[string][]string{"Exercise": {"for"}}, nil), // {Exercise:String} (Delimiter) {Distance:Float}{DistanceUnits} :TODO - delimiter test
		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s+(?:for)\s+(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<DistanceUnits>(ft|foot|feet|mi|mile|miles|m|meter|meters|kilometer|kilometers|km|k)$)`, nil, nil),                                          // {Exercise:String} for {Distance:Float}{DistanceUnits}

		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Time>\d+)\s*(?P<TimeUnits>(s|sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours)$)`, map[string][]string{"Exercise": {"for"}}, nil), // {Exercise:String} (Delimiter) {Time:Number}{TimeUnits}
		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s+(?:for)\s+(?P<Time>\d+)\s*(?P<TimeUnits>(s|sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours)$)`, nil, nil),                                          // {Exercise:String} for {Time:Number}{TimeUnits}

		newExpression(`^(?P<Exercise>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*(?:,+|-|\s)\s*(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<DistanceUnits>ft|foot|feet|mi|mile|miles|m|meter|meters|kilometer|kilometers|km|k)\s*(?:,+|-|\s)\s*(?:in)?\s*(?P<Time>\d+)\s*(?P<TimeUnits>(s|sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours)$)`, nil, nil), // {Exercise:String} (Delimiter) {Distance:Float}{DistanceUnits} (Delimiter) in? {Time:Number}{TimeUnits} :TODO - add delimiter ttest

		newExpression(`^(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<DistanceUnits>ft|foot|feet|mi|mile|miles|m|meter|meters|kilometer|kilometers|km|k)\s*(?:,+|-|\s)\s*(?:in)\s*(?P<Time>\d{1,2}\:\d{2})\s*(?:,+|-|\s)\s*(?P<Exercise>([a-zA-Z,\/\-\s]+[a-zA-Z])$)`, nil, nil),                                                             // {Distance:Float}{DistanceUnits} (Delimiter) in {Time:mm:ss} (Delimiter) {Exercise:String}
		newExpression(`^(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<DistanceUnits>ft|foot|feet|mi|mile|miles|m|meter|meters|kilometer|kilometers|km|k)\s*(?:,+|-|\s)\s*(?:in)\s*(?P<Time>\d+)\s*(?P<TimeUnits>s|sec|secs|seconds|min|mins|minutes|hr|hrs|hour|hours)\s*(?:,+|-|\s)\s*(?P<Exercise>([a-zA-Z,\/\-\s]+[a-zA-Z])$)`, nil, nil), // {Distance:Float}{DistanceUnits} (Delimiter) in {Time:Number}{TimeUnits} (Delimiter) {Exercise:String}
		newExpression(`^(?P<Distance>([0-9]*[.])?[0-9]+)\s*(?P<DistanceUnits>ft|foot|feet|mi|mile|miles|m|meter|meters|kilometer|kilometers|km|k)\s*(?:,+|-|\s)\s*(?:of)?\s*(?P<Exercise>([a-zA-Z,\/\-\s]+[a-zA-Z])$)`, nil, nil),                                                                                                     // {Distance:Float}{DistanceUnits} (Delimiter) of? {Exercise:String} :TODO - delimiter test
		newExpression(`^(?P<Distance>[0-9]*[.][0-9]+)\s*(?P<NotDistanceUnits>ft|foot|feet|mi|mile|miles|m|meter|meters|kilometer|kilometers|km|k)?\s*(?:of)?\s*(?P<Exercise>([a-zA-Z,\/\-\s]+[a-zA-Z])$)`, nil, []string{"NotDistanceUnits"}),                                                                                         // {Distance:Float} of? {Exercise:String} :TODO - delimiter test
	}

	return expressions
}

func activityExerciseExpressions() []*expression {
	expressions := []*expression{
		newExpression(`^(?P<Exercise1>[a-zA-Z,\/\-\s]+[a-zA-Z])\s*with\s*(?P<Exercise2>([a-zA-Z,\/\-\s]+[a-zA-Z])$)`, nil, nil),
	}

	return expressions
}

func resolveActivityExpressions(activity string, regexpSet []*expression) *ParsedActivity {
	activity = strings.Trim(strings.ToLower(activity), " ")

	for i := len(regexpSet) - 1; i >= 0; i-- {
		e := regexpSet[i]

		captures := e.captures(activity)

		if captures != nil {
			return &ParsedActivity{
				Raw:      activity,
				Captures: captures,
				Regex:    e.value,
			}
		}
	}

	return &ParsedActivity{
		Raw: activity,
	}
}

func deepResolveActivityExpressions(activity string, regexpSet []*expression) []*ParsedActivity {
	// 1. try and resolve the entire thing
	parsed := resolveActivityExpressions(activity, regexpSet)

	if parsed.Captures != nil {
		parsed.ParseType = ParseTypeFull
		return []*ParsedActivity{parsed}
	}

	// 2. try and resolve each token seperated by spaces as largest combination (must match to beginning or end - not middle)
	tokens := regexp.MustCompile("[\\s]+").Split(activity, -1) // move out??
	parsedTokens := []*ParsedActivity{}

	for i := len(tokens) - 1; i > 0; i-- { // if we go all the way down to 0 - that would mean we're matching the whole thing which is something that should have happened above
		combined := strings.Join(tokens[:i], " ")
		parsed := resolveActivityExpressions(combined, regexpSet)
		if parsed.Captures != nil {
			parsed.ParseType = ParseTypePartial
			parsedTokens = append(parsedTokens, parsed)
			break
		}
	}

	for i := 1; i < len(tokens); i++ {
		combined := strings.Join(tokens[i:], " ")
		parsed := resolveActivityExpressions(combined, regexpSet)
		if parsed.Captures != nil {
			parsed.ParseType = ParseTypePartial
			parsedTokens = append(parsedTokens, parsed)
			break
		}
	}

	return parsedTokens
}

// Parser allows you to resolve raw exercise strings
type Parser struct {
	lemma                         *lemma
	stopPhrases                   *stopPhrases
	activityExpressions           []*expression
	correctiveActivityExpressions []*expression
	activityExerciseExpressions   []*expression
}

// ResolveActivity returns the captures
func (p *Parser) ResolveActivity(activity string) ([]*ParsedActivity, error) {
	// remove stop phrases
	// exercise = p.stopPhrases.removeStopPhrases(exercise) // I don't think this belongs here - remove at the time we resolve it to a known exercise

	extraCommas := regexp.MustCompile(`(,\s*,)+`)
	activity = extraCommas.ReplaceAllString(activity, ",")

	// resolve expression
	parsedExpressions := deepResolveActivityExpressions(activity, p.activityExpressions)

	if len(parsedExpressions) == 0 {
		return nil, fmt.Errorf("no matches found")
	}

	return parsedExpressions, nil
}

func (p *Parser) ResolveExercise(exercise string) ([]string, error) {
	result := []string{}

	for _, e := range p.activityExerciseExpressions {
		match := e.regexp.FindStringSubmatch(exercise)
		if match == nil {
			continue
		}

		for i, name := range e.regexp.SubexpNames() {
			// Ignore the whole regexp match and unnamed groups
			if i == 0 || name == "" {
				continue
			}

			result = append(result, match[i])
		}
	}

	return result, nil
}

func (p *Parser) ResolveCorrective(activity string) (*ParsedActivity, error) {
	extraCommas := regexp.MustCompile(`(,\s*,)+`)
	activity = extraCommas.ReplaceAllString(activity, ",")

	activity = strings.Trim(strings.ToLower(activity), " ")

	for i := 0; i < len(p.correctiveActivityExpressions); i-- {
		e := p.correctiveActivityExpressions[i]

		captures := e.captures(activity)

		if captures != nil {
			return &ParsedActivity{
				Raw:            activity,
				Captures:       captures,
				Regex:          e.value,
				CorrectiveCode: e.correctiveMessageCode,
			}, nil
		}
	}

	return nil, fmt.Errorf("can't help user with feedback as to what went wrong")
}

func (p *Parser) RemoveStopPhrases(exercise string) string {
	return strings.Trim(p.stopPhrases.removeStopPhrases(exercise), " ")
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
		stopPhrases := newStopPhrases(v)

		parser = &Parser{
			lemma:                         nil,
			stopPhrases:                   stopPhrases,
			activityExpressions:           activityExpressions(),
			correctiveActivityExpressions: correctiveActivityExpressions(),
			activityExerciseExpressions:   activityExerciseExpressions(),
		}
	})

	return err
}

// Get returns global parser object
func Get() *Parser {
	return parser
}
