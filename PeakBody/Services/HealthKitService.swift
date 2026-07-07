import Foundation
import Combine

#if canImport(HealthKit)
import HealthKit
#endif

struct HealthDailySummary: Equatable {
    var date: Date
    var isAvailable: Bool
    var isAuthorized: Bool
    var activeEnergyKcal: Double?
    var exerciseMinutes: Double?
    var sleepHours: Double?
    var messageKey: L10nKey?

    static func unavailable(on date: Date, messageKey: L10nKey) -> HealthDailySummary {
        HealthDailySummary(
            date: date,
            isAvailable: false,
            isAuthorized: false,
            messageKey: messageKey
        )
    }
}

@MainActor
final class HealthKitService: ObservableObject {
    @Published
    var summary: HealthDailySummary?
    @Published
    var isLoading = false
    @Published
    var isEnabled = false
    @Published
    var lastErrorKey: L10nKey?

    private let calendar: Calendar

    #if canImport(HealthKit)
    private let healthStore: HKHealthStore
    #endif

    init(calendar: Calendar = .autoupdatingCurrent) {
        self.calendar = calendar
        #if canImport(HealthKit)
        self.healthStore = HKHealthStore()
        #endif
    }

    func connectAndRefresh(for date: Date) async {
        isEnabled = true
        await refresh(for: date)
    }

    func refresh(for date: Date) async {
        guard isEnabled else {
            summary = HealthDailySummary(
                date: date,
                isAvailable: true,
                isAuthorized: false,
                messageKey: .healthConnectDescription
            )
            return
        }

        #if canImport(HealthKit)
        guard HKHealthStore.isHealthDataAvailable() else {
            summary = .unavailable(on: date, messageKey: .healthUnavailable)
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await requestAuthorizationIfNeeded()
            async let activeEnergy = quantitySum(
                identifier: .activeEnergyBurned,
                unit: .kilocalorie(),
                on: date
            )
            async let exerciseMinutes = quantitySum(
                identifier: .appleExerciseTime,
                unit: .minute(),
                on: date
            )
            async let sleepHours = sleepHours(on: date)

            summary = HealthDailySummary(
                date: date,
                isAvailable: true,
                isAuthorized: true,
                activeEnergyKcal: try await activeEnergy,
                exerciseMinutes: try await exerciseMinutes,
                sleepHours: try await sleepHours
            )
            lastErrorKey = nil
        } catch {
            summary = HealthDailySummary(
                date: date,
                isAvailable: true,
                isAuthorized: false,
                messageKey: .healthPermissionDenied
            )
            lastErrorKey = .healthFetchFailed
        }
        #else
        summary = .unavailable(on: date, messageKey: .healthKitUnavailable)
        #endif
    }
}

#if canImport(HealthKit)
private extension HealthKitService {
    func requestAuthorizationIfNeeded() async throws {
        var readTypes = Set<HKObjectType>()
        if let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
            readTypes.insert(activeEnergy)
        }
        if let exerciseTime = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) {
            readTypes.insert(exerciseTime)
        }
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            readTypes.insert(sleep)
        }

        let _: Void = try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: HealthKitError.authorizationDenied)
                }
            }
        }
    }

    func quantitySum(
        identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        on date: Date
    ) async throws -> Double? {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            return nil
        }

        let interval = calendar.dateInterval(of: .day, for: date)
        guard let interval else { return nil }
        let predicate = HKQuery.predicateForSamples(
            withStart: interval.start,
            end: interval.end,
            options: [.strictStartDate]
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: statistics?.sumQuantity()?.doubleValue(for: unit))
            }
            healthStore.execute(query)
        }
    }

    func sleepHours(on date: Date) async throws -> Double? {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return nil
        }

        // 睡眠は日跨ぎが多いため、選択日の前日昼〜翌日昼を取得し、選択日との重なり時間だけを集計する。
        guard
            let dayInterval = calendar.dateInterval(of: .day, for: date),
            let queryStart = calendar.date(byAdding: .hour, value: -12, to: dayInterval.start),
            let queryEnd = calendar.date(byAdding: .hour, value: 12, to: dayInterval.end)
        else {
            return nil
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: queryStart,
            end: queryEnd,
            options: []
        )

        let samples: [HKCategorySample] = try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: (samples as? [HKCategorySample]) ?? [])
            }
            healthStore.execute(query)
        }

        let asleepValues: Set<Int> = [
            HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            HKCategoryValueSleepAnalysis.asleepCore.rawValue,
            HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
            HKCategoryValueSleepAnalysis.asleepREM.rawValue
        ]

        let seconds = samples
            .filter { asleepValues.contains($0.value) }
            .reduce(0.0) { partial, sample in
                let start = max(sample.startDate, dayInterval.start)
                let end = min(sample.endDate, dayInterval.end)
                return partial + max(0, end.timeIntervalSince(start))
            }

        return seconds / 3600
    }
}

private enum HealthKitError: Error {
    case authorizationDenied
}
#endif

extension HealthKitService {
    static var preview: HealthKitService {
        let service = HealthKitService()
        service.isEnabled = true
        service.summary = HealthDailySummary(
            date: Date(),
            isAvailable: true,
            isAuthorized: true,
            activeEnergyKcal: 380,
            exerciseMinutes: 42,
            sleepHours: 7.2
        )
        return service
    }
}
