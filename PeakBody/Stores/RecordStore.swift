import Foundation
import Combine

@MainActor
final class RecordStore: ObservableObject {
    @Published
    var bodyWeights: [BodyWeightRecord] = []
    @Published
    var meals: [MealRecord] = []
    @Published
    var workouts: [WorkoutSession] = []
    @Published
    var lastErrorKey: L10nKey?

    private let fileManager: FileManager
    private let calendar: Calendar
    private var storeURL: URL {
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return baseURL.appendingPathComponent("PeakBody/records.json", isDirectory: false)
    }

    init(fileManager: FileManager = .default, calendar: Calendar = .autoupdatingCurrent) {
        self.fileManager = fileManager
        self.calendar = calendar
        load()
    }

    func summary(for date: Date) -> DailyRecordSummary {
        DailyRecordSummary(
            date: date,
            bodyWeights: bodyWeights(on: date),
            meals: meals(on: date),
            workouts: workouts(on: date)
        )
    }

    func bodyWeights(on date: Date) -> [BodyWeightRecord] {
        bodyWeights
            .filter { calendar.isDate($0.measuredAt, inSameDayAs: date) }
            .sorted { $0.measuredAt < $1.measuredAt }
    }

    func meals(on date: Date) -> [MealRecord] {
        meals
            .filter { calendar.isDate($0.eatenAt, inSameDayAs: date) }
            .sorted { $0.eatenAt < $1.eatenAt }
    }

    func workouts(on date: Date) -> [WorkoutSession] {
        workouts
            .filter { calendar.isDate($0.performedAt, inSameDayAs: date) }
            .sorted { $0.performedAt < $1.performedAt }
    }

    func addBodyWeight(measuredAt: Date, weightKg: Double, note: String) {
        let previous = bodyWeights
        let record = BodyWeightRecord(measuredAt: measuredAt, weightKg: weightKg, note: note)
        bodyWeights.append(record)
        bodyWeights.sort { $0.measuredAt > $1.measuredAt }
        if !persist() {
            bodyWeights = previous
        }
    }

    func deleteBodyWeight(_ record: BodyWeightRecord) {
        let previous = bodyWeights
        bodyWeights.removeAll { $0.id == record.id }
        if !persist() {
            bodyWeights = previous
        }
    }

    func addMeal(eatenAt: Date, mealType: MealType, items: [FoodItem], note: String) {
        let previous = meals
        let record = MealRecord(eatenAt: eatenAt, mealType: mealType, note: note, items: items)
        meals.append(record)
        meals.sort { $0.eatenAt > $1.eatenAt }
        if !persist() {
            meals = previous
        }
    }

    func deleteMeal(_ record: MealRecord) {
        let previous = meals
        meals.removeAll { $0.id == record.id }
        if !persist() {
            meals = previous
        }
    }

    func addWorkout(performedAt: Date, exercises: [WorkoutExercise], note: String) {
        let previous = workouts
        let record = WorkoutSession(performedAt: performedAt, note: note, exercises: exercises)
        workouts.append(record)
        workouts.sort { $0.performedAt > $1.performedAt }
        if !persist() {
            workouts = previous
        }
    }

    func deleteWorkout(_ record: WorkoutSession) {
        let previous = workouts
        workouts.removeAll { $0.id == record.id }
        if !persist() {
            workouts = previous
        }
    }

    private func load() {
        do {
            let url = storeURL
            guard fileManager.fileExists(atPath: url.path) else { return }
            let data = try Data(contentsOf: url)
            let container = try JSONDecoder.peakBody.decode(PersistedRecords.self, from: data)
            bodyWeights = container.bodyWeights.sorted { $0.measuredAt > $1.measuredAt }
            meals = container.meals.sorted { $0.eatenAt > $1.eatenAt }
            workouts = container.workouts.sorted { $0.performedAt > $1.performedAt }
        } catch {
            lastErrorKey = .loadFailed
        }
    }

    @discardableResult
    private func persist() -> Bool {
        do {
            let url = storeURL
            try fileManager.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let container = PersistedRecords(
                bodyWeights: bodyWeights,
                meals: meals,
                workouts: workouts
            )
            let data = try JSONEncoder.peakBody.encode(container)
            try data.write(to: url, options: [.atomic, .completeFileProtectionUnlessOpen])
            lastErrorKey = nil
            return true
        } catch {
            lastErrorKey = .saveFailed
            return false
        }
    }
}

private struct PersistedRecords: Codable {
    var bodyWeights: [BodyWeightRecord]
    var meals: [MealRecord]
    var workouts: [WorkoutSession]
}

private extension JSONEncoder {
    static var peakBody: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

private extension JSONDecoder {
    static var peakBody: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

extension RecordStore {
    static var preview: RecordStore {
        let store = RecordStore()
        let now = Date()
        store.bodyWeights = [
            BodyWeightRecord(measuredAt: now.addingTimeInterval(-3600), weightKg: 72.4)
        ]
        store.meals = [
            MealRecord(
                eatenAt: now.addingTimeInterval(-7200),
                mealType: .lunch,
                items: [
                    FoodItem(name: "鶏むね弁当", caloriesKcal: 620, proteinG: 42, fatG: 14, carbsG: 78, sortOrder: 0)
                ]
            )
        ]
        store.workouts = [
            WorkoutSession(
                performedAt: now.addingTimeInterval(-10_800),
                exercises: [
                    WorkoutExercise(
                        name: "ベンチプレス",
                        measurementType: .weightReps,
                        sortOrder: 0,
                        sets: [
                            WorkoutSet(weightKg: 60, reps: 10, sortOrder: 0),
                            WorkoutSet(weightKg: 60, reps: 8, sortOrder: 1)
                        ]
                    )
                ]
            )
        ]
        return store
    }
}
