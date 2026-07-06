import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var recordStore: RecordStore
    @EnvironmentObject private var healthKitService: HealthKitService
    @EnvironmentObject private var localization: AppLocalization

    @State private var selectedDate = Date()
    @State private var activeSheet: HomeSheet?
    private let calendar = Calendar.autoupdatingCurrent

    var body: some View {
        let summary = recordStore.summary(for: selectedDate)

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                dateHeader

                bodyWeightCard(summary: summary)
                mealCard(summary: summary)
                workoutCard(summary: summary)
                healthCard(healthSummary: healthKitService.summary)
            }
            .padding()
        }
        .background(PeakTheme.backgroundGradient)
        .groupBoxStyle(PeakNeonGroupBoxStyle())
        .navigationTitle(localization.text(.home))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(localization.text(.recordBodyWeight)) { activeSheet = .bodyWeight(selectedDate) }
                    Button(localization.text(.recordMeal)) { activeSheet = .meal(selectedDate) }
                    Button(localization.text(.recordWorkout)) { activeSheet = .workout(selectedDate) }
                } label: {
                    Label(localization.text(.addRecord), systemImage: "plus.circle.fill")
                }
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
        .task(id: calendar.startOfDay(for: selectedDate)) {
            await healthKitService.refresh(for: selectedDate)
        }
    }

    private var dateHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(PBFormat.dateHeader(selectedDate, language: localization.language))
                .font(.largeTitle.bold())
                .foregroundStyle(PeakTheme.primaryText)
                .accessibilityAddTraits(.isHeader)

            HStack {
                Button {
                    selectedDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                } label: {
                    Label(localization.text(.previousDay), systemImage: "chevron.left")
                }

                Spacer()

                if !calendar.isDateInToday(selectedDate) {
                    Button(localization.text(.backToToday)) {
                        selectedDate = Date()
                    }
                }

                Button {
                    let next = calendar.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    selectedDate = min(next, Date())
                } label: {
                    Label(localization.text(.nextDay), systemImage: "chevron.right")
                }
                .disabled(calendar.isDateInToday(selectedDate))
            }
            .buttonStyle(.bordered)
            .tint(PeakTheme.acidLime)
        }
    }

    private func bodyWeightCard(summary: DailyRecordSummary) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                if let latest = summary.latestBodyWeight {
                    SummaryMetricView(
                        localization.text(.representativeValue),
                        value: PBFormat.weight(latest.weightKg),
                        footnote: localization.text(.recordAtTime, PBFormat.time.string(from: latest.measuredAt))
                    )
                } else {
                    EmptyRecordView(text: localization.text(.bodyWeightNotRecorded), systemImage: "scalemass")
                }

                ForEach(summary.bodyWeights) { record in
                    HStack {
                        Text(PBFormat.time.string(from: record.measuredAt))
                        Spacer()
                        Text(PBFormat.weight(record.weightKg))
                            .monospacedDigit()
                    }
                    .accessibilityElement(children: .combine)
                }

                Button {
                    activeSheet = .bodyWeight(summary.date)
                } label: {
                    Label(localization.text(.recordBodyWeight), systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
        } label: {
            Label(localization.text(.bodyWeight), systemImage: "scalemass.fill")
        }
    }

    private func mealCard(summary: DailyRecordSummary) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                if summary.meals.isEmpty {
                    EmptyRecordView(text: localization.text(.mealNotRecorded), systemImage: "fork.knife")
                } else {
                    HStack {
                        SummaryMetricView(localization.text(.calories), value: PBFormat.calories(summary.mealCalories))
                        SummaryMetricView("PFC", value: "\(PBFormat.grams(summary.mealProtein)) / \(PBFormat.grams(summary.mealFat)) / \(PBFormat.grams(summary.mealCarbs))")
                    }

                    ForEach(summary.meals) { meal in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("\(localization.text(meal.mealType.localizationKey)) \(PBFormat.time.string(from: meal.eatenAt))")
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                Text(PBFormat.calories(meal.totalCalories))
                                    .monospacedDigit()
                            }
                            Text(meal.items.map(\.name).joined(separator: "、"))
                                .font(.caption)
                                .foregroundStyle(PeakTheme.secondaryText)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Button {
                    activeSheet = .meal(summary.date)
                } label: {
                    Label(localization.text(.recordMeal), systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }
        } label: {
            Label(localization.text(.meal), systemImage: "fork.knife")
        }
    }

    private func workoutCard(summary: DailyRecordSummary) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                if summary.workouts.isEmpty {
                    EmptyRecordView(text: localization.text(.workoutNotRecorded), systemImage: "figure.strengthtraining.traditional")
                } else {
                    HStack {
                        SummaryMetricView(localization.text(.session), value: "\(summary.workouts.count)")
                        SummaryMetricView(localization.text(.totalSets), value: "\(summary.workoutSets)")
                        SummaryMetricView(localization.text(.totalVolume), value: "\(PBFormat.number(summary.workoutVolume))kg")
                    }

                    ForEach(summary.workouts) { workout in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(PBFormat.time.string(from: workout.performedAt))
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                Text(localization.text(.setsSuffix, workout.totalSets))
                                    .monospacedDigit()
                            }
                            Text(workout.exerciseNames)
                                .font(.caption)
                                .foregroundStyle(PeakTheme.secondaryText)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Button {
                    activeSheet = .workout(summary.date)
                } label: {
                    Label(localization.text(.recordWorkout), systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }
        } label: {
            Label(localization.text(.workout), systemImage: "figure.strengthtraining.traditional")
        }
    }

    private func healthCard(healthSummary: HealthDailySummary?) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                if healthKitService.isLoading {
                    ProgressView(localization.text(.checkingHealth))
                } else if let healthSummary, healthSummary.isAuthorized {
                    HStack {
                        SummaryMetricView(
                            localization.text(.exerciseTime),
                            value: localization.text(.minutesSuffix, PBFormat.number(healthSummary.exerciseMinutes ?? 0))
                        )
                        SummaryMetricView(localization.text(.activeEnergy), value: PBFormat.calories(healthSummary.activeEnergyKcal ?? 0))
                        SummaryMetricView(
                            localization.text(.sleep),
                            value: localization.text(.hoursSuffix, PBFormat.number(healthSummary.sleepHours ?? 0, fractionDigits: 1))
                        )
                    }
                    Text(localization.text(.healthReferenceDescription))
                        .font(.caption)
                        .foregroundStyle(PeakTheme.secondaryText)
                } else {
                    Text(healthSummary?.messageKey.map { localization.text($0) } ?? localization.text(.healthConnectDescription))
                        .font(.subheadline)
                        .foregroundStyle(PeakTheme.secondaryText)
                    Button {
                        Task { await healthKitService.connectAndRefresh(for: selectedDate) }
                    } label: {
                        Label(localization.text(.healthConnect), systemImage: "heart.text.square")
                    }
                    .buttonStyle(.bordered)
                }
            }
        } label: {
            Label(localization.text(.healthReferenceData), systemImage: "heart.fill")
        }
    }
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
