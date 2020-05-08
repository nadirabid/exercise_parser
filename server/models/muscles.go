package models

import (
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

func muscleSynonyms(muscle string) []string {
	switch muscle {
	case Abductor:
		return AbductorSynonyms
	case ExtensorCarpiUlnaris:
		return ExtensorCarpiUlnarisSynonyms
	case ExtensorPollicisBrevis:
		return ExtensorPollicisBrevisSynonyms
	case EntensorPollicisLongus:
		return EntensorPollicisLongusSynonyms
	case Anconeus:
		return AnconeusSynonyms
	case Adductor:
		return AdductorSynonyms
	case AnteriorDeltoid:
		return AnteriorDeltoidSynonyms
	case Biceps:
		return BicepsSynonyms
	case BicepsFemoris:
		return BicepsFemorisSynonyms
	case Brachioradialis:
		return BrachioradialisSynonyms
	case Coracobrachialis:
		return CoracobrachialisSynonyms
	case ExternalOblique:
		return ExternalObliqueSynonyms
	case FlexorCarpiRadialis:
		return FlexorCarpiRadialisSynonyms
	case FlexorCarpiUlnaris:
		return FlexorCarpiUlnariSynonyms
	case FlexorDigitorumSuperficialis:
		return FlexorDigitorumSuperficialisSynonyms
	case ExtensorDigitorum:
		return ExtensorDigitorumSynonyms
	case GastrocnemiusLateralHead:
		return GastrocnemiusLateralHeadSynonyms
	case GastrocnemiusMedialHead:
		return GastrocnemiusMedialHeadSynonyms
	case Gastrocnemius:
		return GastrocnemiusSynonyms
	case GluteusMaximus:
		return GluteusMaximusSynonyms
	case GluteusMedius:
		return GluteusMediusSynonyms
	case GluteusMinimus:
		return GluteusMinimusSynonyms
	case IliotibialBand:
		return IliotibialBandSynonyms
	case Infraspinatus:
		return InfraspinatusSynonyms
	case LateralDeltoid:
		return LateralDeltoidSynonyms
	case LatissimusDorsi:
		return LatissimusDorsiSynonyms
	case LevatorScapulae:
		return LevatorScapulaeSynonyms
	case Peroneus:
		return PeroneusSynonyms
	case PosteriorDeltoid:
		return PosteriorDeltoidSynonyms
	case RectusAbdominis:
		return RectusAbdominisSynonyms
	case RectusFemoris:
		return RectusFemorisSynonyms
	case RhomboidMajor:
		return RhomboidMajorSynonyms
	case RhomboidMinor:
		return RhomboidMinorSynonyms
	case Sartorius:
		return SartoriusSynonyms
	case Semitendinosus:
		return SemitendinosusSynonyms
	case SerratusAnterior:
		return SerratusAnteriorSynonyms
	case Soleus:
		return SoleusSynonyms
	case Subscapularis:
		return SubscapularisSynonyms
	case Supraspinatus:
		return SupraspinatusSynonyms
	case TeresMajor:
		return TeresMajorSynonyms
	case TeresMinor:
		return TeresMinorSynonyms
	case TransversusAbdominis:
		return TransversusAbdominisSynonyms
	case TrapeziusLowerFibers:
		return TrapeziusLowerFibersSynonyms
	case TrapeziusUpperFibers:
		return TrapeziusUpperFibersSynonyms
	case TrapeziusMiddleFibers:
		return TrapeziusMiddleFibersSynonyms
	case TricepsSurae:
		return TricepsSuraeSynonyms
	case VastusinterMedius:
		return VastusinterMediusSynonyms
	case VastusLateralis:
		return VastusLateralisSynonyms
	case VastusMedialis:
		return VastusMedialisSynonyms
	case TricepsLongHead:
		return TricepsLongHeadSynonyms
	case TricepsLateralHead:
		return TricepsLateralHeadSynonyms
	case Iliocostalis:
		return IliocostalisSynonyms
	case Longissimus:
		return LongissimusSynonyms
	case Spinalis:
		return SpinalisSynonyms
	case PectoralisMinor:
		return PectoralisMinorSynonyms
	case PectoralisMajorClavicular:
		return PectoralisMajorClavicularSynonyms
	case PectoralisMajorSternal:
		return PectoralisMajorSternalSynonyms
	case PsoasMajor:
		return PsoasMajorSynonyms
	case Iliacus:
		return IliacusSynonyms
	case Iliopsoas:
		return IliopsoasSynonyms
	case ErectorSpinae:
		return ErectorSpinaeSynonyms
	case LowerBack:
		return LowerBackSynonyms
	case Forearm:
		return ForearmSynonyms
	case MiddleBack:
		return MiddleBackSynonyms
	case Abductors:
		return AbductorsSynonyms
	case Deltoids:
		return DeltoidsSynonyms
	case Trapezius:
		return TrapeziusSynonyms
	case RotatorCuff:
		return RotatorCuffSynonyms
	case Triceps:
		return TricepsSynonyms
	case Shoulder:
		return ShoulderSynonyms
	case Arm:
		return ArmSynonyms
	case Back:
		return BackSynonyms
	case Glutes:
		return GlutesSynonyms
	case Quadriceps:
		return QuadricepsSynonyms
	case Hamstrings:
		return HamstringsSynonyms
	case Thigh:
		return ThighSynonyms
	case Calves:
		return CalvesSynonyms
	case Legs:
		return LegsSynonyms
	case Abdominals:
		return AbdominalsSynonyms
	case PectoralisMajor:
		return PectoralisMajorSynonyms
	case Pectorals:
		return PectoralsSynonyms
	default:
		fmt.Printf("Unknown muscle: %s\n", muscle)
		return []string{}
	}
}

var spaceRegexp = regexp.MustCompile(`\s+`)

func sanitizeMuscleString(m string) string {
	m = strings.TrimSpace(m)
	m = spaceRegexp.ReplaceAllString(m, " ")
	m = strings.ToLower(m)

	return m
}
