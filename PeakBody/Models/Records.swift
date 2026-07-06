import Foundation

struct BodyWeightRecord: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var measuredAt: Date
    var weightKg: Double
    var note: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

enum MealType: String, CaseIterable, Codable, Identifiable {
    case breakfast
    case lunch
    case dinner
    case snack
    case other

    var id: String { rawValue }

    var localizationKey: L10nKey {
        switch self {
        case .breakfast:
            return .breakfast
        case .lunch:
            return .lunch
        case .dinner:
            return .dinner
        case .snack:
            return .snack
        case .other:
            return .other
        }
    }

    static func inferred(from date: Date, calendar: Calendar = .autoupdatingCurrent) -> MealType {
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 4..<10:
            return .breakfast
        case 10..<15:
            return .lunch
        case 17..<22:
            return .dinner
        default:
            return .other
        }
    }
}

struct FoodItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var caloriesKcal: Double
    var proteinG: Double?
    var fatG: Double?
    var carbsG: Double?
    var sortOrder: Int
}

struct MealRecord: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var eatenAt: Date
    var mealType: MealType
    var note: String = ""
    var items: [FoodItem]
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    var totalCalories: Double {
        items.reduce(0) { $0 + $1.caloriesKcal }
    }

    var totalProtein: Double {
        items.reduce(0) { $0 + ($1.proteinG ?? 0) }
    }

    var totalFat: Double {
        items.reduce(0) { $0 + ($1.fatG ?? 0) }
    }

    var totalCarbs: Double {
        items.reduce(0) { $0 + ($1.carbsG ?? 0) }
    }
}

enum WorkoutMeasurementType: String, CaseIterable, Codable, Identifiable {
    case weightReps
    case repsOnly
    case duration

    var id: String { rawValue }

    var localizationKey: L10nKey {
        switch self {
        case .weightReps:
            return .weightReps
        case .repsOnly:
            return .repsOnly
        case .duration:
            return .duration
        }
    }
}

struct WorkoutSet: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var weightKg: Double?
    var reps: Int?
    var durationSeconds: Int?
    var sortOrder: Int

    var volume: Double {
        guard let weightKg, let reps else { return 0 }
        return weightKg * Double(reps)
    }
}

struct WorkoutExercise: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var measurementType: WorkoutMeasurementType
    var sortOrder: Int
    var sets: [WorkoutSet]

    var totalSets: Int {
        sets.count
    }

    var totalVolume: Double {
        sets.reduce(0) { $0 + $1.volume }
    }
}

struct WorkoutSession: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var performedAt: Date
    var note: String = ""
    var exercises: [WorkoutExercise]
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.totalSets }
    }

    var totalVolume: Double {
        exercises.reduce(0) { $0 + $1.totalVolume }
    }

    var exerciseNames: String {
        exercises.map(\.name).joined(separator: "、")
    }
}

struct DailyRecordSummary {
    var date: Date
    var bodyWeights: [BodyWeightRecord]
    var meals: [MealRecord]
    var workouts: [WorkoutSession]

    var latestBodyWeight: BodyWeightRecord? {
        bodyWeights.sorted { $0.measuredAt > $1.measuredAt }.first
    }

    var mealCalories: Double {
        meals.reduce(0) { $0 + $1.totalCalories }
    }

    var mealProtein: Double {
        meals.reduce(0) { $0 + $1.totalProtein }
    }

    var mealFat: Double {
        meals.reduce(0) { $0 + $1.totalFat }
    }

    var mealCarbs: Double {
        meals.reduce(0) { $0 + $1.totalCarbs }
    }

    var workoutSets: Int {
        workouts.reduce(0) { $0 + $1.totalSets }
    }

    var workoutVolume: Double {
        workouts.reduce(0) { $0 + $1.totalVolume }
    }
}
