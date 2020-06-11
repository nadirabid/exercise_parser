package parser

import "fmt"

const SecondUnit = "second"
const MinuteUnit = "minute"
const HourUnit = "hour"

const FeetUnit = "feet"
const MeterUnit = "meter"
const KilometerUnit = "kilometer"
const MileUnit = "mile"

const PoundUnit = "pound"
const KilogramUnit = "kilogram"

func unitClassify(unitStr string) (string, error) {
	switch unitStr {
	case "s", "sec", "secs", "second", "seconds":
		return SecondUnit, nil
	case "min", "mins", "minute", "minutes":
		return MinuteUnit, nil
	case "m", "meter", "meters":
		return MeterUnit, nil
	case "k", "km", "kilometer", "kilometers":
		return KilometerUnit, nil
	case "ft", "foot", "feet":
		return FeetUnit, nil
	case "mi", "mils", "mile", "miles":
		return MileUnit, nil
	case "lb", "lbs", "pound", "pounds":
		return PoundUnit, nil
	case "kg", "kgs", "kilos", "kilogram", "kilograms":
		return KilogramUnit, nil
	}

	return "", fmt.Errorf("Unknown unit: %s", unitStr)
}

func UnitStandardize(unitStr string, quantity float32) (float32, error) {
	unit, err := unitClassify(unitStr)
	if err != nil {
		return 0, err
	}

	switch unit {
	case SecondUnit:
		return quantity, nil
	case MinuteUnit:
		return quantity * 60, nil
	case MeterUnit:
		return quantity, nil
	case KilometerUnit:
		return quantity * 1000, nil
	case FeetUnit:
		return quantity * 0.3048, nil
	case MileUnit:
		return quantity * 1609.34, nil
	case PoundUnit:
		return quantity * 0.453592, nil
	case KilogramUnit:
		return quantity, nil
	}

	return 0, fmt.Errorf("Unknown unit: %s", unitStr)
}
