package models

import (
	"exercise_parser/utils"
	"fmt"
	"regexp"
	"strings"
)

const (
	Abductor                     = "abductor"
	ExtensorCarpiUlnaris         = "extensor carpi ulnaris"
	ExtensorPollicisBrevis       = "extensor pollicis brevis"
	EntensorPollicisLongus       = "entensor pollicis longus"
	Anconeus                     = "anconeus"
	Adductor                     = "adductor"
	AnteriorDeltoid              = "anterior deltoid"
	Biceps                       = "biceps"
	BicepsFemoris                = "biceps bemoris"
	Brachioradialis              = "brachioradialis"
	Coracobrachialis             = "coracobrachialis"
	ExternalOblique              = "external obliques"
	FlexorCarpiRadialis          = "flexor carpi radialis"
	FlexorCarpiUlnaris           = "flexor carpi ulnaris"
	FlexorDigitorumSuperficialis = "flexor digitorum superficialis"
	ExtensorDigitorum            = "extensor digitorum"
	GastrocnemiusLateralHead     = "gastrocnemius (lateral head)"
	GastrocnemiusMedialHead      = "gastrocnemius (medial head)"
	Gastrocnemius                = "gastrocnemius"
	GluteusMaximus               = "gluteus maximus"
	GluteusMedius                = "gluteus medius"
	GluteusMinimus               = "gluteus minimus"
	IliotibialBand               = "iliotibial band"
	Infraspinatus                = "infraspinatus"
	LateralDeltoid               = "lateral deltoid"
	LatissimusDorsi              = "latissimus dorsi"
	LevatorScapulae              = "levator scapulae"
	Peroneus                     = "peroneus"
	PosteriorDeltoid             = "posterior deltoid"
	RectusAbdominis              = "rectus abdominis"
	RectusFemoris                = "rectus femoris"
	RhomboidMajor                = "rhomboid major"
	RhomboidMinor                = "rhomboid minor"
	Sartorius                    = "sartorius"
	Semitendinosus               = "semitendinosus"
	SerratusAnterior             = "serratus anterior"
	Soleus                       = "soleus"
	Subscapularis                = "subscapularis"
	Supraspinatus                = "supraspinatus"
	TeresMajor                   = "teres major"
	TeresMinor                   = "teres minor"
	TransversusAbdominis         = "transversus bdominis"
	TrapeziusLowerFibers         = "trapezius (lower fibers)"
	TrapeziusUpperFibers         = "trapezius (upper fibers)"
	TrapeziusMiddleFibers        = "trapezius (middle fibers)"
	TricepsSurae                 = "triceps surae"
	VastusinterMedius            = "vastus intermedius"
	VastusLateralis              = "vastus lateralis"
	VastusMedialis               = "vastus medialis"
	TricepsLongHead              = "triceps (long head)"
	TricepsLateralHead           = "triceps (lateral head)"
	Iliocostalis                 = "iliocostalis"
	Longissimus                  = "longissimus"
	Spinalis                     = "spinalis"
	PectoralisMinor              = "pectoralis minor"
	PectoralisMajorClavicular    = "pectoralis major (clavicular)"
	PectoralisMajorSternal       = "pectoralis major (sternal)"
	PsoasMajor                   = "psoas major"
	Iliacus                      = "iliacus"
	Iliopsoas                    = "oliopsoas"
	ErectorSpinae                = "erector spinae"
	LowerBack                    = "lower back"
	Forearm                      = "forearms"
	MiddleBack                   = "middle back"
	Abductors                    = "abductors"
	Deltoids                     = "deltoids"
	Trapezius                    = "trapezius"
	RotatorCuff                  = "rotator cuff"
	Triceps                      = "triceps"
	Shoulder                     = "shoulders"
	Arm                          = "arm"
	Back                         = "back"
	Glutes                       = "glutes"
	Quadriceps                   = "quadriceps"
	Hamstrings                   = "hamstrings"
	Thigh                        = "thigh"
	Calves                       = "calves"
	Legs                         = "legs"
	Abdominals                   = "abdominals"
	PectoralisMajor              = "pectoralis major"
	Pectorals                    = "pectorals"
)

var allMuscles = []string{
	Abductor,
	ExtensorCarpiUlnaris,
	ExtensorPollicisBrevis,
	EntensorPollicisLongus,
	Anconeus,
	Adductor,
	AnteriorDeltoid,
	Biceps,
	BicepsFemoris,
	Brachioradialis,
	Coracobrachialis,
	ExternalOblique,
	FlexorCarpiRadialis,
	FlexorCarpiUlnaris,
	FlexorDigitorumSuperficialis,
	ExtensorDigitorum,
	GastrocnemiusLateralHead,
	GastrocnemiusMedialHead,
	Gastrocnemius,
	GluteusMaximus,
	GluteusMedius,
	GluteusMinimus,
	IliotibialBand,
	Infraspinatus,
	LateralDeltoid,
	LatissimusDorsi,
	LevatorScapulae,
	Peroneus,
	PosteriorDeltoid,
	RectusAbdominis,
	RectusFemoris,
	RhomboidMajor,
	RhomboidMinor,
	Sartorius,
	Semitendinosus,
	SerratusAnterior,
	Soleus,
	Subscapularis,
	Supraspinatus,
	TeresMajor,
	TeresMinor,
	TransversusAbdominis,
	TrapeziusLowerFibers,
	TrapeziusUpperFibers,
	TrapeziusMiddleFibers,
	TricepsSurae,
	VastusinterMedius,
	VastusLateralis,
	VastusMedialis,
	TricepsLongHead,
	TricepsLateralHead,
	Iliocostalis,
	Longissimus,
	Spinalis,
	PectoralisMinor,
	PectoralisMajorClavicular,
	PectoralisMajorSternal,
	PsoasMajor,
	Iliacus,
	Iliopsoas,
	ErectorSpinae,
	LowerBack,
	Forearm,
	MiddleBack,
	Abductors,
	Deltoids,
	Trapezius,
	RotatorCuff,
	Triceps,
	Shoulder,
	Arm,
	Back,
	Glutes,
	Quadriceps,
	Hamstrings,
	Thigh,
	Calves,
	Legs,
	Abdominals,
	PectoralisMajor,
	Pectorals,
}

var (
	AbductorSynonyms                     = []string{"hip abductors", "tensor fasciae latae"}
	ExtensorCarpiUlnarisSynonyms         = []string{"extensor carpi radialis", "extensor carpi ulnaris"}
	ExtensorPollicisBrevisSynonyms       = []string{}
	EntensorPollicisLongusSynonyms       = []string{}
	AnconeusSynonyms                     = []string{}
	AdductorSynonyms                     = []string{"adductor brevis", "adductor longus", "adductor magnus", "adductors", "aductor brevis", "gracilis", "hip adductors"}
	AnteriorDeltoidSynonyms              = []string{"deltoid, anterior"}
	BicepsSynonyms                       = []string{"biceps brachii", "biceps brachii, short head", "brachialis"}
	BicepsFemorisSynonyms                = []string{}
	BrachioradialisSynonyms              = []string{"brachioradialis"}
	CoracobrachialisSynonyms             = []string{}
	ExternalObliqueSynonyms              = []string{"obliques"}
	FlexorCarpiRadialisSynonyms          = []string{"flexor carpi radialis"}
	FlexorCarpiUlnariSynonyms            = []string{"flexor carpi ulnaris"}
	FlexorDigitorumSuperficialisSynonyms = []string{"wrist extensors", ""}
	ExtensorDigitorumSynonyms            = []string{"wrist/finger flexors"}
	GastrocnemiusLateralHeadSynonyms     = []string{}
	GastrocnemiusMedialHeadSynonyms      = []string{}
	GastrocnemiusSynonyms                = []string{"gastrocnemius"}
	GluteusMaximusSynonyms               = []string{"gluteus maximus", "gluteus maximus, lower fibers"}
	GluteusMediusSynonyms                = []string{"gluteus medius"}
	GluteusMinimusSynonyms               = []string{"gluteus minimus", "gluteus minimus, anterior fibers"}
	IliotibialBandSynonyms               = []string{}
	InfraspinatusSynonyms                = []string{"infraspinatus"}
	LateralDeltoidSynonyms               = []string{"deltoid, lateral"}
	LatissimusDorsiSynonyms              = []string{"latissimus dorsi"}
	LevatorScapulaeSynonyms              = []string{"levator scapulae"}
	PeroneusSynonyms                     = []string{}
	PosteriorDeltoidSynonyms             = []string{"deltoid, posterior"}
	RectusAbdominisSynonyms              = []string{"rectus abdominis"}
	RectusFemorisSynonyms                = []string{"rectus femoris"}
	RhomboidMajorSynonyms                = []string{}
	RhomboidMinorSynonyms                = []string{}
	SartoriusSynonyms                    = []string{"sartorius"}
	SemitendinosusSynonyms               = []string{}
	SerratusAnteriorSynonyms             = []string{"serratus anterior", "serratus anterior, inferior digitations"}
	SoleusSynonyms                       = []string{"soleus"}
	SubscapularisSynonyms                = []string{"subscapularis"}
	SupraspinatusSynonyms                = []string{"supraspinatus"}
	TeresMajorSynonyms                   = []string{"teres major"}
	TeresMinorSynonyms                   = []string{"teres minor"}
	TransversusAbdominisSynonyms         = []string{}
	TrapeziusLowerFibersSynonyms         = []string{"trapezius, lower"}
	TrapeziusUpperFibersSynonyms         = []string{"trapezius, upper", "trapezius, upper (part i)", "trapezius, upper (part ii)", "splenius", "sternocleidomastoid", "sternocleidomastoid, posterior fibers"}
	TrapeziusMiddleFibersSynonyms        = []string{"trapezius, middle"}
	TricepsSuraeSynonyms                 = []string{}
	VastusinterMediusSynonyms            = []string{}
	VastusLateralisSynonyms              = []string{}
	VastusMedialisSynonyms               = []string{}
	TricepsLongHeadSynonyms              = []string{"triceps brachii, long head", "triceps long head", "triceps, long head"}
	TricepsLateralHeadSynonyms           = []string{}
	IliocostalisSynonyms                 = []string{"iliocastalis lumborum", "iliocastalis thoracis"}
	LongissimusSynonyms                  = []string{}
	SpinalisSynonyms                     = []string{}
	PectoralisMinorSynonyms              = []string{"pectoralis minor"}
	PectoralisMajorClavicularSynonyms    = []string{"pectoralis major, clavicular"}
	PectoralisMajorSternalSynonyms       = []string{"pectoralis major (sternal head)", "pectoralis major, sternal"}
	PsoasMajorSynonyms                   = []string{"psoas major"}
	IliacusSynonyms                      = []string{}

	// MARK: Muscle groups

	IliopsoasSynonyms       = []string{"iliopsoas", "gemellus inferior", "gemellus superior", "hip external rotators", "hip flexors", "obturator externus", "obturator internus", "pectineus", "piriformis", "quadratus femoris"}
	ErectorSpinaeSynonyms   = []string{"erector spinae", "erector spinae, cervicis & capitis fibers"}
	LowerBackSynonyms       = []string{"quadratus lumborum"} // Does not map to FMA!
	ForearmSynonyms         = []string{"wrist extensors"}
	MiddleBackSynonyms      = []string{} // Does not map to FMA!
	AbductorsSynonyms       = []string{} // Does not map to FMA!
	DeltoidsSynonyms        = []string{}
	TrapeziusSynonyms       = []string{}
	RotatorCuffSynonyms     = []string{}
	TricepsSynonyms         = []string{"triceps", "triceps brachii"}
	ShoulderSynonyms        = []string{}
	ArmSynonyms             = []string{}
	BackSynonyms            = []string{"rhomboids"}
	GlutesSynonyms          = []string{}
	QuadricepsSynonyms      = []string{"quadriceps"}
	HamstringsSynonyms      = []string{"hamstrings"}
	ThighSynonyms           = []string{}
	CalvesSynonyms          = []string{"soleus"}
	LegsSynonyms            = []string{}
	AbdominalsSynonyms      = []string{}
	PectoralisMajorSynonyms = []string{"pectoralis major"}
	PectoralsSynonyms       = []string{}
)

func muscleSynonyms(muscle string) ([]string, error) {
	switch muscle {
	case Abductor:
		return AbductorSynonyms, nil
	case ExtensorCarpiUlnaris:
		return ExtensorCarpiUlnarisSynonyms, nil
	case ExtensorPollicisBrevis:
		return ExtensorPollicisBrevisSynonyms, nil
	case EntensorPollicisLongus:
		return EntensorPollicisLongusSynonyms, nil
	case Anconeus:
		return AnconeusSynonyms, nil
	case Adductor:
		return AdductorSynonyms, nil
	case AnteriorDeltoid:
		return AnteriorDeltoidSynonyms, nil
	case Biceps:
		return BicepsSynonyms, nil
	case BicepsFemoris:
		return BicepsFemorisSynonyms, nil
	case Brachioradialis:
		return BrachioradialisSynonyms, nil
	case Coracobrachialis:
		return CoracobrachialisSynonyms, nil
	case ExternalOblique:
		return ExternalObliqueSynonyms, nil
	case FlexorCarpiRadialis:
		return FlexorCarpiRadialisSynonyms, nil
	case FlexorCarpiUlnaris:
		return FlexorCarpiUlnariSynonyms, nil
	case FlexorDigitorumSuperficialis:
		return FlexorDigitorumSuperficialisSynonyms, nil
	case ExtensorDigitorum:
		return ExtensorDigitorumSynonyms, nil
	case GastrocnemiusLateralHead:
		return GastrocnemiusLateralHeadSynonyms, nil
	case GastrocnemiusMedialHead:
		return GastrocnemiusMedialHeadSynonyms, nil
	case Gastrocnemius:
		return GastrocnemiusSynonyms, nil
	case GluteusMaximus:
		return GluteusMaximusSynonyms, nil
	case GluteusMedius:
		return GluteusMediusSynonyms, nil
	case GluteusMinimus:
		return GluteusMinimusSynonyms, nil
	case IliotibialBand:
		return IliotibialBandSynonyms, nil
	case Infraspinatus:
		return InfraspinatusSynonyms, nil
	case LateralDeltoid:
		return LateralDeltoidSynonyms, nil
	case LatissimusDorsi:
		return LatissimusDorsiSynonyms, nil
	case LevatorScapulae:
		return LevatorScapulaeSynonyms, nil
	case Peroneus:
		return PeroneusSynonyms, nil
	case PosteriorDeltoid:
		return PosteriorDeltoidSynonyms, nil
	case RectusAbdominis:
		return RectusAbdominisSynonyms, nil
	case RectusFemoris:
		return RectusFemorisSynonyms, nil
	case RhomboidMajor:
		return RhomboidMajorSynonyms, nil
	case RhomboidMinor:
		return RhomboidMinorSynonyms, nil
	case Sartorius:
		return SartoriusSynonyms, nil
	case Semitendinosus:
		return SemitendinosusSynonyms, nil
	case SerratusAnterior:
		return SerratusAnteriorSynonyms, nil
	case Soleus:
		return SoleusSynonyms, nil
	case Subscapularis:
		return SubscapularisSynonyms, nil
	case Supraspinatus:
		return SupraspinatusSynonyms, nil
	case TeresMajor:
		return TeresMajorSynonyms, nil
	case TeresMinor:
		return TeresMinorSynonyms, nil
	case TransversusAbdominis:
		return TransversusAbdominisSynonyms, nil
	case TrapeziusLowerFibers:
		return TrapeziusLowerFibersSynonyms, nil
	case TrapeziusUpperFibers:
		return TrapeziusUpperFibersSynonyms, nil
	case TrapeziusMiddleFibers:
		return TrapeziusMiddleFibersSynonyms, nil
	case TricepsSurae:
		return TricepsSuraeSynonyms, nil
	case VastusinterMedius:
		return VastusinterMediusSynonyms, nil
	case VastusLateralis:
		return VastusLateralisSynonyms, nil
	case VastusMedialis:
		return VastusMedialisSynonyms, nil
	case TricepsLongHead:
		return TricepsLongHeadSynonyms, nil
	case TricepsLateralHead:
		return TricepsLateralHeadSynonyms, nil
	case Iliocostalis:
		return IliocostalisSynonyms, nil
	case Longissimus:
		return LongissimusSynonyms, nil
	case Spinalis:
		return SpinalisSynonyms, nil
	case PectoralisMinor:
		return PectoralisMinorSynonyms, nil
	case PectoralisMajorClavicular:
		return PectoralisMajorClavicularSynonyms, nil
	case PectoralisMajorSternal:
		return PectoralisMajorSternalSynonyms, nil
	case PsoasMajor:
		return PsoasMajorSynonyms, nil
	case Iliacus:
		return IliacusSynonyms, nil
	case Iliopsoas:
		return IliopsoasSynonyms, nil
	case ErectorSpinae:
		return ErectorSpinaeSynonyms, nil
	case LowerBack:
		return LowerBackSynonyms, nil
	case Forearm:
		return ForearmSynonyms, nil
	case MiddleBack:
		return MiddleBackSynonyms, nil
	case Abductors:
		return AbductorsSynonyms, nil
	case Deltoids:
		return DeltoidsSynonyms, nil
	case Trapezius:
		return TrapeziusSynonyms, nil
	case RotatorCuff:
		return RotatorCuffSynonyms, nil
	case Triceps:
		return TricepsSynonyms, nil
	case Shoulder:
		return ShoulderSynonyms, nil
	case Arm:
		return ArmSynonyms, nil
	case Back:
		return BackSynonyms, nil
	case Glutes:
		return GlutesSynonyms, nil
	case Quadriceps:
		return QuadricepsSynonyms, nil
	case Hamstrings:
		return HamstringsSynonyms, nil
	case Thigh:
		return ThighSynonyms, nil
	case Calves:
		return CalvesSynonyms, nil
	case Legs:
		return LegsSynonyms, nil
	case Abdominals:
		return AbdominalsSynonyms, nil
	case PectoralisMajor:
		return PectoralisMajorSynonyms, nil
	case Pectorals:
		return PectoralsSynonyms, nil
	default:
		return []string{}, fmt.Errorf("Unknown muscle: %s\n", muscle)
	}
}

func MuscleStandardName(muscle string) (string, error) {
	m := SanitizeMuscleString(muscle)
	if utils.SliceContainsString(allMuscles, m) {
		return m, nil
	}

	for _, standardMuscleName := range allMuscles {
		if m == standardMuscleName {
			return standardMuscleName, nil
		}

		synonyms, err := muscleSynonyms(standardMuscleName)
		if err != nil {
			return "", err
		}

		if utils.SliceContainsString(synonyms, m) {
			return standardMuscleName, nil
		}
	}

	return "", fmt.Errorf("No freaking clue what this muscle is: %s", muscle)
}

var spaceRegexp = regexp.MustCompile(`\s+`)

func SanitizeMuscleString(m string) string {
	m = strings.TrimSpace(m)
	m = spaceRegexp.ReplaceAllString(m, " ")
	m = strings.ToLower(m)

	return m
}
