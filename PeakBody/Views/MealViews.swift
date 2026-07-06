import SwiftUI

struct MealListView: View {
    @EnvironmentObject private var recordStore: RecordStore
    @EnvironmentObject private var localization: AppLocalization
    @State private var showingForm = false

    var body: some View {
        List {
            if recordStore.meals.isEmpty {
                EmptyRecordView(text: localization.text(.noMealRecords), systemImage: "fork.knife")
            } else {
                ForEach(recordStore.meals) { meal in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(localization.text(meal.mealType.localizationKey))
                                .font(.headline)
                            Spacer()
                            Text(PBFormat.calories(meal.totalCalories))
                                .monospacedDigit()
                        }
                        Text(PBFormat.dateTime(meal.eatenAt, language: localization.language))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(meal.items.map(\.name).joined(separator: "、"))
                            .font(.caption)
                    }
                    .accessibilityElement(children: .combine)
                }
                .onDelete { offsets in
                    for index in offsets {
                        recordStore.deleteMeal(recordStore.meals[index])
                    }
                }
            }
        }
        .peakScrollableSurface()
        .navigationTitle(localization.text(.meal))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingForm = true
                } label: {
                    Label(localization.text(.recordMeal), systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingForm) {
            NavigationStack {
                MealFormView(initialDate: Date())
            }
        }
    }
}

struct MealFormView: View {
    @EnvironmentObject private var recordStore: RecordStore
    @EnvironmentObject private var localization: AppLocalization
    @Environment(\.dismiss) private var dismiss

    @State private var eatenAt: Date
    @State private var mealType: MealType
    @State private var items: [FoodItemDraft] = [FoodItemDraft(sortOrder: 0)]
    @State private var note = ""

    init(initialDate: Date) {
        _eatenAt = State(initialValue: initialDate)
        _mealType = State(initialValue: MealType.inferred(from: initialDate))
    }

    private var totals: (calories: Double, protein: Double, fat: Double, carbs: Double) {
        var calories = 0.0
        var protein = 0.0
        var fat = 0.0
        var carbs = 0.0
        for item in items {
            calories += Double(item.caloriesText) ?? 0
            protein += Double(item.proteinText) ?? 0
            fat += Double(item.fatText) ?? 0
            carbs += Double(item.carbsText) ?? 0
        }
        return (calories, protein, fat, carbs)
    }

    private var canSave: Bool {
        guard eatenAt <= Date(), !items.isEmpty else { return false }
        return items.allSatisfy { item in
            !item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            (Double(item.caloriesText) ?? -1) >= 0
        }
    }

    var body: some View {
        Form {
            Section(localization.text(.dateTypeSection)) {
                DatePicker(localization.text(.eatenAt), selection: $eatenAt, in: ...Date())
                Picker(localization.text(.mealType), selection: $mealType) {
                    ForEach(MealType.allCases) { type in
                        Text(localization.text(type.localizationKey)).tag(type)
                    }
                }
            }

            Section(localization.text(.currentTotals)) {
                HStack {
                    SummaryMetricView(localization.text(.calories), value: PBFormat.calories(totals.calories))
                    SummaryMetricView("PFC", value: "\(PBFormat.grams(totals.protein)) / \(PBFormat.grams(totals.fat)) / \(PBFormat.grams(totals.carbs))")
                }
            }

            Section(localization.text(.food)) {
                ForEach($items) { $item in
                    VStack(alignment: .leading, spacing: 10) {
                        TextField(localization.text(.foodName), text: $item.name)
                        HStack {
                            TextField("kcal", text: $item.caloriesText)
                                .peakKeyboard(.decimal)
                            Text("kcal")
                                .foregroundStyle(.secondary)
                        }
                        DisclosureGroup(localization.text(.pfcOptional)) {
                            TextField(localization.text(.proteinG), text: $item.proteinText)
                                .peakKeyboard(.decimal)
                            TextField(localization.text(.fatG), text: $item.fatText)
                                .peakKeyboard(.decimal)
                            TextField(localization.text(.carbsG), text: $item.carbsText)
                                .peakKeyboard(.decimal)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { items.remove(atOffsets: $0) }

                Button {
                    items.append(FoodItemDraft(sortOrder: items.count))
                } label: {
                    Label(localization.text(.addFood), systemImage: "plus")
                }
            }

            Section(localization.text(.noteOptional)) {
                TextField(localization.text(.note), text: $note, axis: .vertical)
                    .lineLimit(2...4)
            }

            if !canSave {
                Section {
                    Text(localization.text(.mealValidationHint))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .peakScrollableSurface()
        .navigationTitle(localization.text(.recordMeal))
        .peakInlineNavigationTitle()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(localization.text(.cancel)) { dismiss() }
            }
            SaveToolbar(canSave: canSave) {
                let foodItems = items.enumerated().map { index, draft in
                    FoodItem(
                        name: draft.name.trimmingCharacters(in: .whitespacesAndNewlines),
                        caloriesKcal: Double(draft.caloriesText) ?? 0,
                        proteinG: Double(draft.proteinText),
                        fatG: Double(draft.fatText),
                        carbsG: Double(draft.carbsText),
                        sortOrder: index
                    )
                }
                recordStore.addMeal(eatenAt: eatenAt, mealType: mealType, items: foodItems, note: note)
                dismiss()
            }
        }
    }
}

private struct FoodItemDraft: Identifiable {
    var id = UUID()
    var name = ""
    var caloriesText = ""
    var proteinText = ""
    var fatText = ""
    var carbsText = ""
    var sortOrder: Int
}
