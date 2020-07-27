import Foundation

// MARK: Enums

// Using the integer part of the FMA ID as the raw value. There
// are a few items that don't map directly to the FMA, so integer
// values have been generated for these items. It appears that
// FMA IDs start at 10000, so non-FMA integers in the range of
// [10,1000] have been reserved for this purpose.
enum Muscle: Int64, CaseIterable {

    // MARK: individual muscles

    case Abductor = 74997
    case ExtensorCarpiUlnaris = 38506
    case ExtensorPollicisBrevis = 38518
    case EntensorPollicisLongus = 38521
    case Anconeus = 37704
    case Adductor = 74998
    case AnteriorDeltoid = 83003
    case Biceps = 37670
    case BicepsFemoris = 22356
    case Brachioradialis = 38485
    case Coracobrachialis = 37664
    case ExternalOblique = 13335
    case FlexorCarpiRadialis = 38459
    case FlexorCarpiUlnaris = 38465
    case FlexorDigitorumSuperficialis = 38469
    case ExtensorDigitorum = 38500
    case GastrocnemiusLateralHead = 45959
    case GastrocnemiusMedialHead = 45956
    case Gastrocnemius = 22541
    case GluteusMaximus = 22314
    case GluteusMedius = 22315
    case GluteusMinimus = 22317
    case IliotibialBand = 51048
    case Infraspinatus = 32546
    case LateralDeltoid = 83006
    case LatissimusDorsi = 13357
    case LevatorScapulae = 32519
    case Peroneus = 22538
    case PosteriorDeltoid = 83007
    case RectusAbdominis = 9628
    case RectusFemoris = 22430
    case RhomboidMajor = 13379
    case RhomboidMinor = 13380
    case Sartorius = 22353
    case Semitendinosus = 22357
    case SerratusAnterior = 13397
    case Soleus = 22542
    case Subscapularis = 13413
    case Supraspinatus = 9629
    case TeresMajor = 32549
    case TeresMinor = 32550
    case TransversusAbdominis = 15570
    case TrapeziusLowerFibers = 32555
    case TrapeziusUpperFibers = 32557
    case TrapeziusMiddleFibers = 32556
    case TricepsSurae = 51062
    case VastusinterMedius = 22433
    case VastusLateralis = 22431
    case VastusMedialis = 22432
    case TricepsLongHead = 37692
    case TricepsLateralHead = 37694
    case Iliocostalis = 77177
    case Longissimus = 77178
    case Spinalis = 77179
    case PectoralisMinor = 13109
    case PectoralisMajorClavicular = 34687
    case PectoralisMajorSternal = 34696
    case PsoasMajor = 18060
    case Iliacus = 22310

    // MARK: Muscle groups

    case Iliopsoas = 64918
    case ErectorSpinae = 71302
    case LowerBack = 10 // Does not map to FMA!
    case Forearm = 37371
    case MiddleBack = 11 // Does not map to FMA!
    case Abductors = 12 // Does not map to FMA!
    case Deltoids = 32521
    case Trapezius = 9626
    case RotatorCuff = 82650
    case Triceps = 37688
    case Shoulder = 33531
    case Arm = 37370
    case Back = 85216
    case Glutes = 64922
    case Quadriceps = 22428
    case Hamstrings = 81022
    case Thigh = 50208
    case Calves = 65004
    case Legs = 9622
    case Abdominals = 78435
    case PectoralisMajor = 9627
    case Pectorals = 50223
    
    // MARK: Other
    case Unknown = 0
    case Body = 1
    case Background = 2
}

enum MuscleUsage: String {
    case target = "TargetMuscle" // i guess also known as agonist?
    case synergist = "SynergistMuscle"
    case stabilizer = "StabilizerMuscle"
    case dynamicStabilizer = "DynamicStabilizer"
    case antagonistStabilizer = "AntagonistStabilizer"
    case dynamicArticulation = "DynamicArticulation"
    case staticArticulation = "StaticArticulation"
    case none = "None"
}

struct MuscleActivation {
    let muscle: Muscle
    let activation: Double
    
    init(muscle: Muscle) {
        self.muscle = muscle
        self.activation = 1 // value between 0 and 1
    }
    
    init(muscle: Muscle, activation: Double) {
        self.muscle = muscle
        self.activation = activation
    }
}

enum AnatomicalOrientation {
    case Anterior
    case Posterior
}

// MARK: extensions

extension Muscle {
    var isMuscleGroup: Bool {
        return !components.isEmpty
    }

    // MARK: muscle components
    
    var components: [Muscle] {
        switch self {
        case .Iliopsoas: return [.PsoasMajor,.Iliacus]
        case .ErectorSpinae: return [.Iliocostalis,.Longissimus,.Spinalis]
        case .LowerBack: return [.ErectorSpinae]
        case .Forearm: return [.Anconeus,.FlexorCarpiUlnaris,.Brachioradialis,.ExtensorDigitorum,.ExtensorCarpiUlnaris,.ExtensorPollicisBrevis,.EntensorPollicisLongus,.FlexorCarpiRadialis,.FlexorDigitorumSuperficialis]
        case .MiddleBack: return [.RhomboidMajor,.TrapeziusLowerFibers]
        case .Abductors: return [.GluteusMinimus,.GluteusMedius]
        case .Deltoids: return [.AnteriorDeltoid,.LateralDeltoid,.PosteriorDeltoid]
        case .Trapezius: return [.TrapeziusLowerFibers,.TrapeziusUpperFibers,.TrapeziusMiddleFibers]
        case .RotatorCuff: return [.Infraspinatus,.TeresMinor,.Subscapularis,.Supraspinatus]
        case .Triceps: return [.TricepsLongHead,.TricepsLateralHead]
        case .Shoulder: return [.Deltoids,.RotatorCuff,.TeresMajor]
        case .Arm: return [.Biceps,.Triceps,.Forearm,.Shoulder]
        case .Back: return [.LatissimusDorsi,.RhomboidMajor,.RhomboidMinor,.Infraspinatus,.TeresMajor,.TeresMinor,.ErectorSpinae]
        case .Glutes: return [.GluteusMaximus,.GluteusMedius]
        case .Quadriceps: return [.Adductor,.RectusFemoris,.VastusLateralis,.VastusMedialis]
        case .Hamstrings: return [.BicepsFemoris,.Semitendinosus,.IliotibialBand]
        case .Thigh: return [.Quadriceps,.Hamstrings]
        case .Calves: return [.Peroneus,.Soleus,.GastrocnemiusMedialHead,.GastrocnemiusLateralHead]
        case .Gastrocnemius: return [.GastrocnemiusMedialHead, .GastrocnemiusLateralHead]
        case .Legs: return [.Thigh,.Calves]
        case .Abdominals: return [.RectusAbdominis,.ExternalOblique,.SerratusAnterior]
        case .PectoralisMajor: return [.PectoralisMajorSternal,.PectoralisMajorClavicular]
        case .Pectorals: return [.PectoralisMajor,.PectoralisMinor]
        default: return []
        }
    }

    // MARK: muscle names
    
    var name: String {
        switch self {
        case .Abductor: return "Abductor"
        case .ExtensorCarpiUlnaris: return "Extensor Carpi Ulnaris"
        case .ExtensorPollicisBrevis: return "Extensor Pollicis Brevis"
        case .EntensorPollicisLongus: return "Entensor Pollicis Longus"
        case .Anconeus: return "Anconeus"
        case .Adductor: return "Adductor"
        case .AnteriorDeltoid: return "Anterior Deltoid"
        case .Biceps: return "Biceps"
        case .BicepsFemoris: return "Biceps Femoris"
        case .Brachioradialis: return "Brachioradialis"
        case .Coracobrachialis: return "Coracobrachialis"
        case .ExternalOblique: return "External Obliques"
        case .FlexorCarpiRadialis: return "Flexor Carpi Radialis"
        case .FlexorCarpiUlnaris: return "Flexor Carpi Ulnaris"
        case .FlexorDigitorumSuperficialis: return "Flexor Digitorum Superficialis"
        case .ExtensorDigitorum: return "Extensor Digitorum"
        case .GastrocnemiusLateralHead: return "Gastrocnemius (Lateral head)"
        case .GastrocnemiusMedialHead: return "Gastrocnemius (Medial Head)"
        case .Gastrocnemius: return "Gastrocnemius"
        case .GluteusMaximus: return "Gluteus Maximus"
        case .GluteusMedius: return "Gluteus Medius"
        case .GluteusMinimus: return "Gluteus Minimus"
        case .IliotibialBand: return "Iliotibial Band"
        case .Infraspinatus: return "Infraspinatus"
        case .LateralDeltoid: return "Lateral Deltoid"
        case .LatissimusDorsi: return "Latissimus dorsi"
        case .LevatorScapulae: return "Levator scapulae"
        case .Peroneus: return "Peroneus"
        case .PosteriorDeltoid: return "Posterior Deltoid"
        case .RectusAbdominis: return "Rectus Abdominis"
        case .RectusFemoris: return "Rectus Femoris"
        case .RhomboidMajor: return "Rhomboid Major"
        case .RhomboidMinor: return "Rhomboid Minor"
        case .Sartorius: return "Sartorius"
        case .Semitendinosus: return "Semitendinosus"
        case .SerratusAnterior: return "Serratus Anterior"
        case .Soleus: return "Soleus"
        case .Subscapularis: return "Subscapularis"
        case .Supraspinatus: return "Supraspinatus"
        case .TeresMajor: return "Teres Major"
        case .TeresMinor: return "Teres Minor"
        case .TransversusAbdominis: return "Transversus Abdominis"
        case .TrapeziusLowerFibers: return "Trapezius (Lower Fibers)"
        case .TrapeziusUpperFibers: return "Trapezius (Upper Fibers)"
        case .TrapeziusMiddleFibers: return "Trapezius (Middle Fibers)"
        case .TricepsSurae: return "Triceps surae"
        case .VastusinterMedius: return "Vastus interMedius"
        case .VastusLateralis: return "Vastus Lateralis"
        case .VastusMedialis: return "Vastus Medialis"
        case .TricepsLongHead: return "Triceps (Long Head)"
        case .TricepsLateralHead: return "Triceps (Lateral Head)"
        case .Iliocostalis: return "Iliocostalis"
        case .Longissimus: return "Longissimus"
        case .Spinalis: return "Spinalis"
        case .PectoralisMinor: return "Pectoralis Minor"
        case .PectoralisMajorClavicular: return "Pectoralis Major (Clavicular)"
        case .PectoralisMajorSternal: return "Pectoralis Major (Sternal)"
        case .PsoasMajor: return "Psoas Major"
        case .Iliacus: return "Iliacus"
        case .Iliopsoas: return "Iliopsoas"
        case .ErectorSpinae: return "Erector spinae"
        case .LowerBack: return "Lower Back"
        case .Forearm: return "Forearms"
        case .MiddleBack: return "Middle Back"
        case .Abductors: return "Abductors"
        case .Deltoids: return "Deltoids"
        case .Trapezius: return "Trapezius"
        case .RotatorCuff: return "Rotator Cuff"
        case .Triceps: return "Triceps"
        case .Shoulder: return "Shoulders"
        case .Arm: return "Arm"
        case .Back: return "Back"
        case .Glutes: return "Glutes"
        case .Quadriceps: return "Quadriceps"
        case .Hamstrings: return "Hamstrings"
        case .Thigh: return "Thigh"
        case .Calves: return "Calves"
        case .Legs: return "Legs"
        case .Abdominals: return "Abdominals"
        case .PectoralisMajor: return "Pectoralis Major"
        case .Pectorals: return "Pectorals"
        case .Unknown: return "Unknown"
        case .Body: return "Body"
        case .Background: return "Background"
        }
    }
    
    static func from(name: String) -> Muscle? {
        let lowercased = name.lowercased()
        let muscle = Muscle.allCases.first(where: { $0.name.lowercased() == lowercased })
        return muscle
    }
}

extension Muscle {
    var orientation: AnatomicalOrientation {
        switch self {
        case .Abductor: return .Posterior
        case .ExtensorCarpiUlnaris: return .Posterior
        case .ExtensorPollicisBrevis: return .Posterior
        case .EntensorPollicisLongus: return .Posterior
        case .Anconeus: return .Posterior
        case .Adductor: return .Anterior
        case .AnteriorDeltoid: return .Anterior
        case .Biceps: return .Anterior
        case .BicepsFemoris: return .Posterior
        case .Brachioradialis: return .Anterior
        case .Coracobrachialis: return .Anterior
        case .ExternalOblique: return .Anterior
        case .FlexorCarpiRadialis: return .Anterior
        case .FlexorCarpiUlnaris: return .Anterior
        case .FlexorDigitorumSuperficialis: return .Anterior
        case .ExtensorDigitorum: return .Posterior
        case .GastrocnemiusLateralHead: return .Posterior
        case .GastrocnemiusMedialHead: return .Posterior
        case .Gastrocnemius: return .Posterior
        case .GluteusMaximus: return .Posterior
        case .GluteusMedius: return .Posterior
        case .GluteusMinimus: return .Posterior
        case .IliotibialBand: return .Posterior
        case .Infraspinatus: return .Posterior
        case .LateralDeltoid: return .Anterior
        case .LatissimusDorsi: return .Posterior
        case .LevatorScapulae: return .Posterior
        case .Peroneus: return .Anterior
        case .PosteriorDeltoid: return .Posterior
        case .RectusAbdominis: return .Anterior
        case .RectusFemoris: return .Anterior
        case .RhomboidMajor: return .Posterior
        case .RhomboidMinor: return .Posterior
        case .Sartorius: return .Anterior
        case .Semitendinosus: return .Posterior
        case .SerratusAnterior: return .Anterior
        case .Soleus: return .Anterior
        case .Subscapularis: return .Anterior
        case .Supraspinatus: return .Posterior
        case .TeresMajor: return .Posterior
        case .TeresMinor: return .Posterior
        case .TransversusAbdominis: return .Anterior
        case .TrapeziusLowerFibers: return .Posterior
        case .TrapeziusUpperFibers: return .Posterior
        case .TrapeziusMiddleFibers: return .Posterior
        case .TricepsSurae: return .Posterior
        case .VastusinterMedius: return .Anterior
        case .VastusLateralis: return .Anterior
        case .VastusMedialis: return .Anterior
        case .TricepsLongHead: return .Posterior
        case .TricepsLateralHead: return .Posterior
        case .Iliocostalis: return .Posterior
        case .Longissimus: return .Posterior
        case .Spinalis: return .Posterior
        case .PectoralisMinor: return .Anterior
        case .PectoralisMajorClavicular: return .Anterior
        case .PectoralisMajorSternal: return .Anterior
        case .PsoasMajor: return .Anterior
        case .Iliacus: return .Anterior
        case .Iliopsoas: return .Anterior
        case .ErectorSpinae: return .Posterior
        case .LowerBack: return .Posterior
        case .Forearm: return .Anterior
        case .MiddleBack: return .Posterior
        case .Abductors: return .Posterior
        case .Deltoids: return .Anterior
        case .Trapezius: return .Posterior
        case .RotatorCuff: return .Posterior
        case .Triceps: return .Posterior
        case .Shoulder: return .Posterior
        case .Arm: return .Anterior
        case .Back: return .Posterior
        case .Glutes: return .Posterior
        case .Quadriceps: return .Anterior
        case .Hamstrings: return .Posterior
        case .Thigh: return .Anterior
        case .Calves: return .Posterior
        case .Legs: return .Anterior
        case .Abdominals: return .Anterior
        case .PectoralisMajor: return .Anterior
        case .Pectorals: return .Anterior
        case .Unknown: return .Anterior
        case .Body: return .Anterior
        case .Background: return .Anterior
        }
    }
}

extension Muscle {
    var weight: Int {
        switch self {
        case .Abductor: return 1
        case .ExtensorCarpiUlnaris: return 1
        case .ExtensorPollicisBrevis: return 1
        case .EntensorPollicisLongus: return 1
        case .Anconeus: return 1
        case .Adductor: return 1
        case .AnteriorDeltoid: return 1
        case .Biceps: return 1
        case .BicepsFemoris: return 1
        case .Brachioradialis: return 1
        case .Coracobrachialis: return 1
        case .ExternalOblique: return 1
        case .FlexorCarpiRadialis: return 1
        case .FlexorCarpiUlnaris: return 1
        case .FlexorDigitorumSuperficialis: return 1
        case .ExtensorDigitorum: return 1
        case .GastrocnemiusLateralHead: return 1
        case .GastrocnemiusMedialHead: return 1
        case .Gastrocnemius: return 1
        case .GluteusMaximus: return 1
        case .GluteusMedius: return 1
        case .GluteusMinimus: return 1
        case .IliotibialBand: return 1
        case .Infraspinatus: return 1
        case .LateralDeltoid: return 1
        case .LatissimusDorsi: return 1
        case .LevatorScapulae: return 1
        case .Peroneus: return 1
        case .PosteriorDeltoid: return 1
        case .RectusAbdominis: return 1
        case .RectusFemoris: return 1
        case .RhomboidMajor: return 1
        case .RhomboidMinor: return 1
        case .Sartorius: return 1
        case .Semitendinosus: return 1
        case .SerratusAnterior: return 1
        case .Soleus: return 1
        case .Subscapularis: return 1
        case .Supraspinatus: return 1
        case .TeresMajor: return 1
        case .TeresMinor: return 1
        case .TransversusAbdominis: return 1
        case .TrapeziusLowerFibers: return 1
        case .TrapeziusUpperFibers: return 1
        case .TrapeziusMiddleFibers: return 1
        case .TricepsSurae: return 1
        case .VastusinterMedius: return 1
        case .VastusLateralis: return 1
        case .VastusMedialis: return 1
        case .TricepsLongHead: return 1
        case .TricepsLateralHead: return 1
        case .Iliocostalis: return 1
        case .Longissimus: return 1
        case .Spinalis: return 1
        case .PectoralisMinor: return 1
        case .PectoralisMajorClavicular: return 1
        case .PectoralisMajorSternal: return 1
        case .PsoasMajor: return 1
        case .Iliacus: return 1
        case .Iliopsoas: return 1
        case .ErectorSpinae: return 1
        case .LowerBack: return 1
        case .Forearm: return 1
        case .MiddleBack: return 1
        case .Abductors: return 1
        case .Deltoids: return 1
        case .Trapezius: return 1
        case .RotatorCuff: return 1
        case .Triceps: return 1
        case .Shoulder: return 1
        case .Arm: return 1
        case .Back: return 1
        case .Glutes: return 1
        case .Quadriceps: return 1
        case .Hamstrings: return 1
        case .Thigh: return 1
        case .Calves: return 1
        case .Legs: return 1
        case .Abdominals: return 1
        case .PectoralisMajor: return 1
        case .Pectorals: return 1
        case .Unknown: return 1
        case .Body: return 1
        case .Background: return 1
        }
    }
}
