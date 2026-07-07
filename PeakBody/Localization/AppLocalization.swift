import Foundation
import Combine

enum AppLanguage: String, CaseIterable, Codable, Identifiable {
    case ja
    case en

    var id: String { rawValue }

    var localeIdentifier: String {
        switch self {
        case .ja:
            return "ja_JP"
        case .en:
            return "en_US"
        }
    }

    var displayName: String {
        switch self {
        case .ja:
            return "日本語"
        case .en:
            return "English"
        }
    }
}

enum L10nKey: String {
    case appName
    case home
    case workout
    case meal
    case bodyWeight
    case settings
    case language
    case displayLanguage
    case close
    case cancel
    case save
    case addRecord
    case previousDay
    case nextDay
    case backToToday
    case representativeValue
    case recordAtTime
    case bodyWeightNotRecorded
    case recordBodyWeight
    case mealNotRecorded
    case recordMeal
    case workoutNotRecorded
    case recordWorkout
    case calories
    case session
    case totalSets
    case totalVolume
    case healthReferenceData
    case checkingHealth
    case exerciseTime
    case activeEnergy
    case sleep
    case healthReferenceDescription
    case healthConnect
    case healthConnectDescription
    case healthUnavailable
    case healthPermissionDenied
    case healthFetchFailed
    case healthKitUnavailable
    case noBodyWeightRecords
    case noMealRecords
    case noWorkoutRecords
    case weightSection
    case dateTimeSection
    case noteOptional
    case measuredAt
    case eatenAt
    case mealType
    case performedAt
    case weightRequired
    case weightNumeric
    case weightRange
    case futureDateInvalid
    case exampleAfterWaking
    case dateTypeSection
    case currentTotals
    case food
    case foodName
    case addFood
    case pfcOptional
    case proteinG
    case fatG
    case carbsG
    case note
    case mealValidationHint
    case exercise
    case exerciseName
    case measurementType
    case addSet
    case addExercise
    case seconds
    case reps
    case workoutValidationHint
    case loadFailed
    case saveFailed
    case breakfast
    case lunch
    case dinner
    case snack
    case other
    case weightReps
    case repsOnly
    case duration
    case benchPress
    case setsSuffix
    case minutesSuffix
    case hoursSuffix
}

@MainActor
final class AppLocalization: ObservableObject {
    @Published
    var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: Self.storageKey)
        }
    }

    private static let storageKey = "app.displayLanguage"

    init() {
        if
            let rawValue = UserDefaults.standard.string(forKey: Self.storageKey),
            let storedLanguage = AppLanguage(rawValue: rawValue)
        {
            self.language = storedLanguage
        } else {
            self.language = .ja
        }
    }

    var locale: Locale {
        Locale(identifier: language.localeIdentifier)
    }

    func text(_ key: L10nKey) -> String {
        Self.translations[language]?[key]
            ?? Self.translations[.ja]?[key]
            ?? key.rawValue
    }

    func text(_ key: L10nKey, _ arguments: CVarArg...) -> String {
        String(format: text(key), locale: locale, arguments: arguments)
    }
}

private extension AppLocalization {
    static let translations: [AppLanguage: [L10nKey: String]] = [
        .ja: [
            .appName: "Peak Body",
            .home: "ホーム",
            .workout: "筋トレ",
            .meal: "食事",
            .bodyWeight: "体重",
            .settings: "設定",
            .language: "言語",
            .displayLanguage: "表示言語",
            .close: "閉じる",
            .cancel: "キャンセル",
            .save: "保存",
            .addRecord: "記録を追加",
            .previousDay: "前日",
            .nextDay: "翌日",
            .backToToday: "今日へ戻る",
            .representativeValue: "日次代表値",
            .recordAtTime: "%@ の記録",
            .bodyWeightNotRecorded: "この日の体重は未記録です",
            .recordBodyWeight: "体重を記録",
            .mealNotRecorded: "この日の食事は未記録です",
            .recordMeal: "食事を記録",
            .workoutNotRecorded: "この日の筋トレは未記録です",
            .recordWorkout: "筋トレを記録",
            .calories: "カロリー",
            .session: "セッション",
            .totalSets: "総セット",
            .totalVolume: "総ボリューム",
            .healthReferenceData: "ヘルスケア参考データ",
            .checkingHealth: "ヘルスケアを確認中",
            .exerciseTime: "運動時間",
            .activeEnergy: "消費",
            .sleep: "睡眠",
            .healthReferenceDescription: "ヘルスケアから取得した参考値です。手入力の筋トレ記録とは別に扱います。",
            .healthConnect: "ヘルスケアを連携",
            .healthConnectDescription: "許可すると、ヘルスケアの運動時間・消費エネルギー・睡眠時間を参考表示できます。",
            .healthUnavailable: "この端末ではヘルスケア連携を利用できません。",
            .healthPermissionDenied: "ヘルスケアの読み取り許可がないため、運動・睡眠データは表示していません。",
            .healthFetchFailed: "ヘルスケアデータを取得できませんでした。",
            .healthKitUnavailable: "HealthKitを利用できない環境です。",
            .noBodyWeightRecords: "まだ体重記録がありません",
            .noMealRecords: "まだ食事記録がありません",
            .noWorkoutRecords: "まだ筋トレ記録がありません",
            .weightSection: "体重",
            .dateTimeSection: "日時",
            .noteOptional: "メモ（任意）",
            .measuredAt: "計測日時",
            .eatenAt: "食事日時",
            .mealType: "食事区分",
            .performedAt: "実施日時",
            .weightRequired: "体重を入力してください。",
            .weightNumeric: "体重は数値で入力してください。",
            .weightRange: "体重は20.0〜500.0kgで入力してください。",
            .futureDateInvalid: "未来日時は登録できません。",
            .exampleAfterWaking: "例: 起床後",
            .dateTypeSection: "日時・区分",
            .currentTotals: "入力中の合計",
            .food: "食品",
            .foodName: "食品名",
            .addFood: "食品を追加",
            .pfcOptional: "PFC（任意）",
            .proteinG: "タンパク質 g",
            .fatG: "脂質 g",
            .carbsG: "炭水化物 g",
            .note: "メモ",
            .mealValidationHint: "食品名とカロリーを入力してください。未来日時は登録できません。",
            .exercise: "種目",
            .exerciseName: "種目名",
            .measurementType: "計測方式",
            .addSet: "セットを追加",
            .addExercise: "種目を追加",
            .seconds: "秒",
            .reps: "回数",
            .workoutValidationHint: "種目名と1セット以上の有効な値を入力してください。未来日時は登録できません。",
            .loadFailed: "保存済みデータを読み込めませんでした。既存データは変更せず、再起動後に再試行してください。",
            .saveFailed: "保存できませんでした。入力内容を確認し、もう一度保存してください。",
            .breakfast: "朝食",
            .lunch: "昼食",
            .dinner: "夕食",
            .snack: "間食",
            .other: "その他",
            .weightReps: "重量 × 回数",
            .repsOnly: "回数のみ",
            .duration: "時間",
            .benchPress: "ベンチプレス",
            .setsSuffix: "%dセット",
            .minutesSuffix: "%@分",
            .hoursSuffix: "%@時間"
        ],
        .en: [
            .appName: "Peak Body",
            .home: "Home",
            .workout: "Workout",
            .meal: "Meals",
            .bodyWeight: "Weight",
            .settings: "Settings",
            .language: "Language",
            .displayLanguage: "Display Language",
            .close: "Close",
            .cancel: "Cancel",
            .save: "Save",
            .addRecord: "Add Record",
            .previousDay: "Previous",
            .nextDay: "Next",
            .backToToday: "Today",
            .representativeValue: "Daily value",
            .recordAtTime: "Recorded at %@",
            .bodyWeightNotRecorded: "No weight recorded for this day",
            .recordBodyWeight: "Record Weight",
            .mealNotRecorded: "No meals recorded for this day",
            .recordMeal: "Record Meal",
            .workoutNotRecorded: "No workouts recorded for this day",
            .recordWorkout: "Record Workout",
            .calories: "Calories",
            .session: "Sessions",
            .totalSets: "Total Sets",
            .totalVolume: "Total Volume",
            .healthReferenceData: "Health Reference Data",
            .checkingHealth: "Checking Health data",
            .exerciseTime: "Exercise",
            .activeEnergy: "Energy",
            .sleep: "Sleep",
            .healthReferenceDescription: "Reference values from Apple Health. These are separate from manually entered workout records.",
            .healthConnect: "Connect Health",
            .healthConnectDescription: "Allow access to show exercise time, active energy, and sleep time from Apple Health.",
            .healthUnavailable: "Health data is not available on this device.",
            .healthPermissionDenied: "Health read permission is not granted, so exercise and sleep data are hidden.",
            .healthFetchFailed: "Could not fetch Health data.",
            .healthKitUnavailable: "HealthKit is unavailable in this environment.",
            .noBodyWeightRecords: "No weight records yet",
            .noMealRecords: "No meal records yet",
            .noWorkoutRecords: "No workout records yet",
            .weightSection: "Weight",
            .dateTimeSection: "Date & Time",
            .noteOptional: "Note (optional)",
            .measuredAt: "Measured at",
            .eatenAt: "Meal time",
            .mealType: "Meal type",
            .performedAt: "Performed at",
            .weightRequired: "Enter your weight.",
            .weightNumeric: "Weight must be a number.",
            .weightRange: "Weight must be between 20.0 and 500.0 kg.",
            .futureDateInvalid: "Future dates cannot be saved.",
            .exampleAfterWaking: "Example: after waking",
            .dateTypeSection: "Date & Type",
            .currentTotals: "Current Totals",
            .food: "Food",
            .foodName: "Food name",
            .addFood: "Add Food",
            .pfcOptional: "Macros (optional)",
            .proteinG: "Protein g",
            .fatG: "Fat g",
            .carbsG: "Carbs g",
            .note: "Note",
            .mealValidationHint: "Enter a food name and calories. Future dates cannot be saved.",
            .exercise: "Exercise",
            .exerciseName: "Exercise name",
            .measurementType: "Measurement type",
            .addSet: "Add Set",
            .addExercise: "Add Exercise",
            .seconds: "sec",
            .reps: "Reps",
            .workoutValidationHint: "Enter an exercise name and at least one valid set. Future dates cannot be saved.",
            .loadFailed: "Could not load saved data. Existing data was not changed. Try again after restarting the app.",
            .saveFailed: "Could not save. Check the input and try again.",
            .breakfast: "Breakfast",
            .lunch: "Lunch",
            .dinner: "Dinner",
            .snack: "Snack",
            .other: "Other",
            .weightReps: "Weight × Reps",
            .repsOnly: "Reps only",
            .duration: "Duration",
            .benchPress: "Bench Press",
            .setsSuffix: "%d sets",
            .minutesSuffix: "%@ min",
            .hoursSuffix: "%@ hr"
        ]
    ]
}
