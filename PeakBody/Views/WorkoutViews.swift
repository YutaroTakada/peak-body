import SwiftUI

struct WorkoutListView: View {
    @EnvironmentObject private var recordStore: RecordStore
    @EnvironmentObject private var localization: AppLocalization
    @State private var showingForm = false

    var body: some View {
        List {
            if recordStore.workouts.isEmpty {
                EmptyRecordView(text: localization.text(.noWorkoutRecords), systemImage: "figure.strengthtraining.traditional")
            } else {
                ForEach(recordStore.workouts) { workout in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(PBFormat.dateTime(workout.performedAt, language: localization.language))
                                .font(.headline)
                            Spacer()
                            Text(localization.text(.setsSuffix, workout.totalSets))
                                .monospacedDigit()
                        }
                        Text(workout.exerciseNames)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(localization.text(.totalVolume)) \(PBFormat.number(workout.totalVolume))kg")
                            .font(.caption)
                    }
                    .accessibilityElement(children: .combine)
                }
                .onDelete { offsets in
                    for index in offsets {
                        recordStore.deleteWorkout(recordStore.workouts[index])
                    }
                }
            }
        }
        .peakScrollableSurface()
        .navigationTitle(localization.text(.workout))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingForm = true
                } label: {
                    Label(localization.text(.recordWorkout), systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingForm) {
            NavigationStack {
                WorkoutFormView(initialDate: Date())
            }
        }
    }
}

struct WorkoutFormView: View {
    @EnvironmentObject private var recordStore: RecordStore
    @EnvironmentObject private var localization: AppLocalization
    @Environment(\.dismiss) private var dismiss

    @State private var performedAt: Date
    @State private var exercises: [WorkoutExerciseDraft] = [WorkoutExerciseDraft(sortOrder: 0)]
    @State private var note = ""

    init(initialDate: Date) {
        _performedAt = State(initialValue: initialDate)
    }

    private var totalSets: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }

    private var totalVolume: Double {
        var volume = 0.0
        for exercise in exercises {
            for set in exercise.sets {
                volume += (Double(set.weightText) ?? 0) * Double(Int(set.repsText) ?? 0)
            }
        }
        return volume
    }

    private var canSave: Bool {
        guard performedAt <= Date(), !exercises.isEmpty else { return false }
        return exercises.allSatisfy { exercise in
            !exercise.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !exercise.sets.isEmpty &&
            exercise.sets.allSatisfy { set in
                switch exercise.measurementType {
                case .weightReps:
                    return (Double(set.weightText) ?? -1) >= 0 && (Int(set.repsText) ?? 0) > 0
                case .repsOnly:
                    return (Int(set.repsText) ?? 0) > 0
                case .duration:
                    return (Int(set.durationText) ?? 0) > 0
                }
            }
        }
    }

    var body: some View {
        Form {
            Section(localization.text(.dateTimeSection)) {
                DatePicker(localization.text(.performedAt), selection: $performedAt, in: ...Date())
            }

            Section(localization.text(.currentTotals)) {
                HStack {
                    SummaryMetricView(localization.text(.totalSets), value: "\(totalSets)")
                    SummaryMetricView(localization.text(.totalVolume), value: "\(PBFormat.number(totalVolume))kg")
                }
            }

            Section(localization.text(.exercise)) {
                ForEach($exercises) { $exercise in
                    VStack(alignment: .leading, spacing: 12) {
                        TextField(localization.text(.exerciseName), text: $exercise.name)
                        Picker(localization.text(.measurementType), selection: $exercise.measurementType) {
                            ForEach(WorkoutMeasurementType.allCases) { type in
                                Text(localization.text(type.localizationKey)).tag(type)
                            }
                        }

                        ForEach($exercise.sets) { $set in
                            HStack {
                                if exercise.measurementType == .weightReps {
                                    TextField("kg", text: $set.weightText)
                                        .peakKeyboard(.decimal)
                                    Text("kg")
                                        .foregroundStyle(.secondary)
                                }

                                if exercise.measurementType == .duration {
                                    TextField(localization.text(.seconds), text: $set.durationText)
                                        .peakKeyboard(.number)
                                    Text(localization.text(.seconds))
                                        .foregroundStyle(.secondary)
                                } else {
                                    TextField(localization.text(.reps), text: $set.repsText)
                                        .peakKeyboard(.number)
                                    Text(localization.text(.reps))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete { exercise.sets.remove(atOffsets: $0) }

                        Button {
                            exercise.sets.append(exercise.sets.last?.copy(sortOrder: exercise.sets.count) ?? WorkoutSetDraft(sortOrder: exercise.sets.count))
                        } label: {
                            Label(localization.text(.addSet), systemImage: "plus")
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onDelete { exercises.remove(atOffsets: $0) }

                Button {
                    exercises.append(WorkoutExerciseDraft(sortOrder: exercises.count))
                } label: {
                    Label(localization.text(.addExercise), systemImage: "plus")
                }
            }

            Section(localization.text(.noteOptional)) {
                TextField(localization.text(.note), text: $note, axis: .vertical)
                    .lineLimit(2...4)
            }

            if !canSave {
                Section {
                    Text(localization.text(.workoutValidationHint))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .peakScrollableSurface()
        .navigationTitle(localization.text(.recordWorkout))
        .peakInlineNavigationTitle()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(localization.text(.cancel)) { dismiss() }
            }
            SaveToolbar(canSave: canSave) {
                let mappedExercises = exercises.enumerated().map { exerciseIndex, draft in
                    WorkoutExercise(
                        name: draft.name.trimmingCharacters(in: .whitespacesAndNewlines),
                        measurementType: draft.measurementType,
                        sortOrder: exerciseIndex,
                        sets: draft.sets.enumerated().map { setIndex, set in
                            WorkoutSet(
                                weightKg: Double(set.weightText),
                                reps: Int(set.repsText),
                                durationSeconds: Int(set.durationText),
                                sortOrder: setIndex
                            )
                        }
                    )
                }
                recordStore.addWorkout(performedAt: performedAt, exercises: mappedExercises, note: note)
                dismiss()
            }
        }
    }
}

private struct WorkoutExerciseDraft: Identifiable {
    var id = UUID()
    var name = ""
    var measurementType: WorkoutMeasurementType = .weightReps
    var sortOrder: Int
    var sets: [WorkoutSetDraft] = [WorkoutSetDraft(sortOrder: 0)]
}

private struct WorkoutSetDraft: Identifiable {
    var id = UUID()
    var weightText = ""
    var repsText = ""
    var durationText = ""
    var sortOrder: Int

    func copy(sortOrder: Int) -> WorkoutSetDraft {
        WorkoutSetDraft(
            weightText: weightText,
            repsText: repsText,
            durationText: durationText,
            sortOrder: sortOrder
        )
    }
}
