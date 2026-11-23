import SwiftUI

/// SCR-01 カレンダー・日詳細（メイン画面）。
/// 主役は「選んだ日の記録」。カレンダーで日を選び、その下で体重・食事・筋トレ・消費カロリーを見る。
struct HomeView: View {
    @EnvironmentObject private var recordStore: RecordStore
    @EnvironmentObject private var healthKitService: HealthKitService
    @EnvironmentObject private var localization: AppLocalization

    @State private var selectedDay: Date
    @State private var displayedMonth: Date
    @State private var activeSheet: HomeSheet?
    private let calendar = Calendar.autoupdatingCurrent

    init() {
        let calendar = Calendar.autoupdatingCurrent
        let today = calendar.startOfDay(for: Date())
        _selectedDay = State(initialValue: today)
        _displayedMonth = State(initialValue: calendar.dateInterval(of: .month, for: today)?.start ?? today)
    }

    var body: some View {
        let summary = recordStore.summary(for: selectedDay)

        ScrollView {
            VStack(alignment: .leading, spacing: PeakSpacing.xl) {
                PeakCard {
                    MonthCalendarView(
                        selectedDay: $selectedDay,
                        displayedMonth: $displayedMonth,
                        flags: monthFlags
                    )
                }

                VStack(alignment: .leading, spacing: PeakSpacing.sm) {
                    Text(PBFormat.dateHeader(selectedDay, language: localization.language))
                        .font(PeakTypography.heading)
                        .foregroundStyle(PeakColor.textPrimary)
                        .accessibilityAddTraits(.isHeader)

                    bodyWeightSection(summary: summary)
                    mealSection(summary: summary)
                    workoutSection(summary: summary)
                    activeEnergySection
                }
            }
            .padding(.horizontal, PeakSpacing.md)
            .padding(.top, PeakSpacing.xs)
            // 左下の設定ボタンに最後のカードが隠れないよう、ボタンの高さ分の余白を取る
            .padding(.bottom, PeakSize.minTapTarget + PeakSpacing.xxl)
        }
        .background(PeakColor.background)
        .navigationTitle(localization.text(.calendar))
        .peakInlineNavigationTitle()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button { activeSheet = .bodyWeight(entryDate) } label: {
                        Label(localization.text(.recordBodyWeight), systemImage: "scalemass")
                    }
                    Button { activeSheet = .meal(entryDate) } label: {
                        Label(localization.text(.recordMeal), systemImage: "fork.knife")
                    }
                    Button { activeSheet = .workout(entryDate) } label: {
                        Label(localization.text(.recordWorkout), systemImage: "figure.strengthtraining.traditional")
                    }
                } label: {
                    Label(localization.text(.addRecord), systemImage: "plus")
                }
            }
        }
        .navigationDestination(for: DayRecordDestination.self) { destination in
            switch destination {
            case .bodyWeight(let day):
                BodyWeightListView(day: day)
            case .meal(let day):
                MealListView(day: day)
            case .workout(let day):
                WorkoutListView(day: day)
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .bodyWeight(let date):
                NavigationStack { BodyWeightFormView(initialDate: date) }
            case .meal(let date):
                NavigationStack { MealFormView(initialDate: date) }
            case .workout(let date):
                NavigationStack { WorkoutFormView(initialDate: date) }
            }
        }
        .task(id: selectedDay) {
            await healthKitService.refresh(for: selectedDay)
        }
    }

    /// 入力画面を開くときの日時（選択日を引き継ぐ）
    private var entryDate: Date {
        recordEntryDate(on: selectedDay)
    }

    private var monthFlags: [Date: DayRecordFlags] {
        guard let interval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [:] }
        return recordStore.recordFlags(in: interval)
    }

    // MARK: - 日詳細の各項目

    private func bodyWeightSection(summary: DailyRecordSummary) -> some View {
        DayRecordSection(
            title: localization.text(.bodyWeight),
            systemImage: "scalemass",
            addLabel: localization.text(.recordBodyWeight),
            destination: summary.bodyWeights.isEmpty ? nil : DayRecordDestination.bodyWeight(selectedDay),
            onAdd: { activeSheet = .bodyWeight(entryDate) }
        ) {
            if let latest = summary.latestBodyWeight {
                VStack(alignment: .leading, spacing: PeakSpacing.xs) {
                    MetricLine(
                        value: PBFormat.weight(latest.weightKg),
                        detail: localization.text(.latestAt, PBFormat.time.string(from: latest.measuredAt))
                    )
                    if summary.bodyWeights.count > 1 {
                        ForEach(summary.bodyWeights) { record in
                            RecordRow(
                                leading: PBFormat.time.string(from: record.measuredAt),
                                detail: nil,
                                trailing: PBFormat.weight(record.weightKg)
                            )
                        }
                    }
                }
            } else {
                NotRecordedText()
            }
        }
    }

    private func mealSection(summary: DailyRecordSummary) -> some View {
        DayRecordSection(
            title: localization.text(.meal),
            systemImage: "fork.knife",
            addLabel: localization.text(.recordMeal),
            destination: summary.meals.isEmpty ? nil : DayRecordDestination.meal(selectedDay),
            onAdd: { activeSheet = .meal(entryDate) }
        ) {
            if summary.meals.isEmpty {
                NotRecordedText()
            } else {
                VStack(alignment: .leading, spacing: PeakSpacing.xs) {
                    MetricLine(
                        value: PBFormat.calories(summary.mealCalories),
                        detail: [
                            "\(localization.text(.protein)) \(PBFormat.grams(summary.mealProtein))",
                            "\(localization.text(.fat)) \(PBFormat.grams(summary.mealFat))",
                            "\(localization.text(.carbs)) \(PBFormat.grams(summary.mealCarbs))"
                        ].joined(separator: "  ")
                    )
                    ForEach(summary.meals) { meal in
                        RecordRow(
                            leading: "\(localization.text(meal.mealType.localizationKey)) \(PBFormat.time.string(from: meal.eatenAt))",
                            detail: meal.items.map(\.name).joined(separator: "、"),
                            trailing: PBFormat.calories(meal.totalCalories)
                        )
                    }
                }
            }
        }
    }

    private func workoutSection(summary: DailyRecordSummary) -> some View {
        DayRecordSection(
            title: localization.text(.workout),
            systemImage: "figure.strengthtraining.traditional",
            addLabel: localization.text(.recordWorkout),
            destination: summary.workouts.isEmpty ? nil : DayRecordDestination.workout(selectedDay),
            onAdd: { activeSheet = .workout(entryDate) }
        ) {
            if summary.workouts.isEmpty {
                NotRecordedText()
            } else {
                let exerciseCount = summary.workouts.reduce(0) { $0 + $1.exercises.count }
                VStack(alignment: .leading, spacing: PeakSpacing.xs) {
                    MetricLine(
                        value: "\(PBFormat.number(summary.workoutVolume))kg",
                        detail: [
                            localization.text(.sessionsSuffix, summary.workouts.count),
                            localization.text(.exercisesSuffix, exerciseCount),
                            localization.text(.setsSuffix, summary.workoutSets)
                        ].joined(separator: localization.text(.listSeparator))
                    )
                    ForEach(summary.workouts) { workout in
                        RecordRow(
                            leading: PBFormat.time.string(from: workout.performedAt),
                            detail: workout.exerciseNames,
                            trailing: localization.text(.setsSuffix, workout.totalSets)
                        )
                    }
                }
            }
        }
    }

    /// 消費カロリー（HealthKit 読み取りのみ。保存・端末外送信はしない）
    private var activeEnergySection: some View {
        DayRecordSection(
            title: localization.text(.activeEnergyTitle),
            systemImage: "flame",
            addLabel: nil,
            destination: nil,
            onAdd: nil
        ) {
            if healthKitService.isLoading {
                ProgressView(localization.text(.checkingHealth))
                    .font(PeakTypography.supporting)
                    .foregroundStyle(PeakColor.textSecondary)
            } else if let health = healthKitService.summary, health.isAuthorized {
                VStack(alignment: .leading, spacing: PeakSpacing.xxs) {
                    MetricLine(
                        value: health.activeEnergyKcal.map(PBFormat.calories) ?? localization.text(.noHealthData),
                        detail: healthDetail(health)
                    )
                    Text(localization.text(.healthEnergyNote))
                        .font(PeakTypography.caption)
                        .foregroundStyle(PeakColor.textSecondary)
                }
            } else {
                VStack(alignment: .leading, spacing: PeakSpacing.sm) {
                    Text(healthKitService.summary?.messageKey.map { localization.text($0) } ?? localization.text(.healthConnectDescription))
                        .font(PeakTypography.supporting)
                        .foregroundStyle(PeakColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if healthKitService.summary?.isAvailable ?? true {
                        Button(localization.text(.healthConnect)) {
                            Task { await healthKitService.connectAndRefresh(for: selectedDay) }
                        }
                        .buttonStyle(PeakSecondaryButtonStyle())
                    }
                }
            }
        }
    }

    private func healthDetail(_ health: HealthDailySummary) -> String? {
        var parts: [String] = []
        if let minutes = health.exerciseMinutes {
            parts.append(localization.text(.exerciseTimeValue, PBFormat.number(minutes)))
        }
        if let hours = health.sleepHours, hours > 0 {
            parts.append(localization.text(.sleepValue, PBFormat.number(hours, fractionDigits: 1)))
        }
        return parts.isEmpty ? nil : parts.joined(separator: localization.text(.listSeparator))
    }
}

// MARK: - 日詳細の部品

/// 日詳細の1項目。見出し行（名前と＋）と、その日の概要。概要をタップするとその日の一覧へ進む。
private struct DayRecordSection<Summary: View>: View {
    let title: String
    let systemImage: String
    let addLabel: String?
    let destination: DayRecordDestination?
    let onAdd: (() -> Void)?
    @ViewBuilder let summary: () -> Summary

    var body: some View {
        PeakCard {
            VStack(alignment: .leading, spacing: PeakSpacing.xs) {
                HStack(spacing: PeakSpacing.xs) {
                    Label(title, systemImage: systemImage)
                        .font(PeakTypography.heading)
                        .foregroundStyle(PeakColor.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    Spacer(minLength: PeakSpacing.xs)
                    if let onAdd, let addLabel {
                        PeakIconButton(systemImage: "plus", accessibilityLabel: addLabel, action: onAdd)
                    }
                }
                .frame(minHeight: PeakSize.minTapTarget)

                if let destination {
                    NavigationLink(value: destination) {
                        HStack(alignment: .center, spacing: PeakSpacing.xs) {
                            summary()
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(PeakTypography.supporting)
                                .foregroundStyle(PeakColor.textSecondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                } else {
                    summary()
                }
            }
        }
    }
}

/// 主役の数値1つと、補足1行。
private struct MetricLine: View {
    let value: String
    let detail: String?

    var body: some View {
        VStack(alignment: .leading, spacing: PeakSpacing.xxs) {
            Text(value)
                .font(PeakTypography.metric)
                .foregroundStyle(PeakColor.textPrimary)
            if let detail {
                Text(detail)
                    .font(PeakTypography.supporting)
                    .monospacedDigit()
                    .foregroundStyle(PeakColor.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// 記録1件の行。上に細い罫線を引き、箱の入れ子にしない。
private struct RecordRow: View {
    let leading: String
    let detail: String?
    let trailing: String

    var body: some View {
        VStack(alignment: .leading, spacing: PeakSpacing.xs) {
            Divider()
                .overlay(PeakColor.border)
            HStack(alignment: .firstTextBaseline, spacing: PeakSpacing.sm) {
                VStack(alignment: .leading, spacing: PeakSpacing.xxxs) {
                    Text(leading)
                        .font(PeakTypography.label)
                        .foregroundStyle(PeakColor.textPrimary)
                    if let detail, !detail.isEmpty {
                        Text(detail)
                            .font(PeakTypography.supporting)
                            .foregroundStyle(PeakColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: PeakSpacing.xs)
                Text(trailing)
                    .font(PeakTypography.body)
                    .monospacedDigit()
                    .foregroundStyle(PeakColor.textPrimary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct NotRecordedText: View {
    @EnvironmentObject private var localization: AppLocalization

    var body: some View {
        Text(localization.text(.notRecorded))
            .font(PeakTypography.supporting)
            .foregroundStyle(PeakColor.textSecondary)
    }
}

/// 日詳細から進む、その日の一覧
enum DayRecordDestination: Hashable {
    case bodyWeight(Date)
    case meal(Date)
    case workout(Date)
}

private enum HomeSheet: Identifiable {
    case bodyWeight(Date)
    case meal(Date)
    case workout(Date)

    var id: String {
        switch self {
        case .bodyWeight(let date): "bodyWeight-\(date.timeIntervalSince1970)"
        case .meal(let date): "meal-\(date.timeIntervalSince1970)"
        case .workout(let date): "workout-\(date.timeIntervalSince1970)"
        }
    }
}
