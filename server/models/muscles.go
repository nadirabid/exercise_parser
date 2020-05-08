package models

import (
	"fmt"
	"regexp"
	"strings"
)

const (
	Abductor                     = "Abductor"
	ExtensorCarpiUlnaris         = "Extensor Carpi Ulnaris"
	ExtensorPollicisBrevis       = "Extensor Pollicis Brevis"
	EntensorPollicisLongus       = "Entensor Pollicis Longus"
	Anconeus                     = "Anconeus"
	Adductor                     = "Adductor"
	AnteriorDeltoid              = "Anterior Deltoid"
	Biceps                       = "Biceps"
	BicepsFemoris                = "Biceps Femoris"
	Brachioradialis              = "Brachioradialis"
	Coracobrachialis             = "Coracobrachialis"
	ExternalOblique              = "External Obliques"
	FlexorCarpiRadialis          = "Flexor Carpi Radialis"
	FlexorCarpiUlnaris           = "Flexor Carpi Ulnaris"
	FlexorDigitorumSuperficialis = "Flexor Digitorum Superficialis"
	ExtensorDigitorum            = "Extensor Digitorum"
	GastrocnemiusLateralHead     = "Gastrocnemius (Lateral head)"
	GastrocnemiusMedialHead      = "Gastrocnemius (Medial Head)"
	Gastrocnemius                = "Gastrocnemius"
	GluteusMaximus               = "Gluteus Maximus"
	GluteusMedius                = "Gluteus Medius"
	GluteusMinimus               = "Gluteus Minimus"
	IliotibialBand               = "Iliotibial Band"
	Infraspinatus                = "Infraspinatus"
	LateralDeltoid               = "Lateral Deltoid"
	LatissimusDorsi              = "Latissimus dorsi"
	LevatorScapulae              = "Levator scapulae"
	Peroneus                     = "Peroneus"
	PosteriorDeltoid             = "Posterior Deltoid"
	RectusAbdominis              = "Rectus Abdominis"
	RectusFemoris                = "Rectus Femoris"
	RhomboidMajor                = "Rhomboid Major"
	RhomboidMinor                = "Rhomboid Minor"
	Sartorius                    = "Sartorius"
	Semitendinosus               = "Semitendinosus"
	SerratusAnterior             = "Serratus Anterior"
	Soleus                       = "Soleus"
	Subscapularis                = "Subscapularis"
	Supraspinatus                = "Supraspinatus"
	TeresMajor                   = "Teres Major"
	TeresMinor                   = "Teres Minor"
	TransversusAbdominis         = "Transversus Abdominis"
	TrapeziusLowerFibers         = "Trapezius (Lower Fibers)"
	TrapeziusUpperFibers         = "Trapezius (Upper Fibers)"
	TrapeziusMiddleFibers        = "Trapezius (Middle Fibers)"
	TricepsSurae                 = "Triceps surae"
	VastusinterMedius            = "Vastus interMedius"
	VastusLateralis              = "Vastus Lateralis"
	VastusMedialis               = "Vastus Medialis"
	TricepsLongHead              = "Triceps (Long Head)"
	TricepsLateralHead           = "Triceps (Lateral Head)"
	Iliocostalis                 = "Iliocostalis"
	Longissimus                  = "Longissimus"
	Spinalis                     = "Spinalis"
	PectoralisMinor              = "Pectoralis Minor"
	PectoralisMajorClavicular    = "Pectoralis Major (Clavicular)"
	PectoralisMajorSternal       = "Pectoralis Major (Sternal)"
	PsoasMajor                   = "Psoas Major"
	Iliacus                      = "Iliacus"
	Iliopsoas                    = "Iliopsoas"
	ErectorSpinae                = "Erector spinae"
	LowerBack                    = "Lower Back"
	Forearm                      = "Forearms"
	MiddleBack                   = "Middle Back"
	Abductors                    = "Abductors"
	Deltoids                     = "Deltoids"
	Trapezius                    = "Trapezius"
	RotatorCuff                  = "Rotator Cuff"
	Triceps                      = "Triceps"
	Shoulder                     = "Shoulders"
	Arm                          = "Arm"
	Back                         = "Back"
	Glutes                       = "Glutes"
	Quadriceps                   = "Quadriceps"
	Hamstrings                   = "Hamstrings"
	Thigh                        = "Thigh"
	Calves                       = "Calves"
	Legs                         = "Legs"
	Abdominals                   = "Abdominals"
	PectoralisMajor              = "Pectoralis Major"
	Pectorals                    = "Pectorals"
	Unknown                      = "Unknown"
	Body                         = "Body"
	Background                   = "Background"
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
	case Unknown:
		return []string{}
	case Body:
		return []string{}
	case Background:
		return []string{}
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
