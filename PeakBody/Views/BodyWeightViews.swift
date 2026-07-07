import SwiftUI

struct BodyWeightListView: View {
    @EnvironmentObject private var recordStore: RecordStore
    @EnvironmentObject private var localization: AppLocalization
    @State private var showingForm = false

    var body: some View {
        List {
            if recordStore.bodyWeights.isEmpty {
                EmptyRecordView(text: localization.text(.noBodyWeightRecords), systemImage: "scalemass")
            } else {
                ForEach(recordStore.bodyWeights) { record in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(PBFormat.weight(record.weightKg))
                            .font(.headline)
                            .monospacedDigit()
                        Text(PBFormat.dateTime(record.measuredAt, language: localization.language))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if !record.note.isEmpty {
                            Text(record.note)
                                .font(.caption)
                        }
                    }
                    .accessibilityElement(children: .combine)
                }
                .onDelete { offsets in
                    for index in offsets {
                        recordStore.deleteBodyWeight(recordStore.bodyWeights[index])
                    }
                }
            }
        }
        .peakScrollableSurface()
        .navigationTitle(localization.text(.bodyWeight))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingForm = true
                } label: {
                    Label(localization.text(.recordBodyWeight), systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingForm) {
            NavigationStack {
                BodyWeightFormView(initialDate: Date())
            }
        }
    }
}

struct BodyWeightFormView: View {
    @EnvironmentObject private var recordStore: RecordStore
    @EnvironmentObject private var localization: AppLocalization
    @Environment(\.dismiss) private var dismiss

    @State private var measuredAt: Date
    @State private var weightText = ""
    @State private var note = ""

    init(initialDate: Date) {
        _measuredAt = State(initialValue: initialDate)
    }

    private var weight: Double? {
        Double(weightText.replacingOccurrences(of: ",", with: "."))
    }

    private var validationMessage: String? {
        guard !weightText.isEmpty else { return localization.text(.weightRequired) }
        guard let weight else { return localization.text(.weightNumeric) }
        guard (20.0...500.0).contains(weight) else { return localization.text(.weightRange) }
        guard measuredAt <= Date() else { return localization.text(.futureDateInvalid) }
        return nil
    }

    var body: some View {
        Form {
            Section(localization.text(.weightSection)) {
                HStack {
                    TextField("72.4", text: $weightText)
                        .peakKeyboard(.decimal)
                        .font(.title2.monospacedDigit())
                    Text("kg")
                        .foregroundStyle(.secondary)
                }
                if let validationMessage {
                    Text(validationMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Section(localization.text(.dateTimeSection)) {
                DatePicker(localization.text(.measuredAt), selection: $measuredAt, in: ...Date())
            }

            Section(localization.text(.noteOptional)) {
                TextField(localization.text(.exampleAfterWaking), text: $note, axis: .vertical)
                    .lineLimit(2...4)
            }

            if let errorKey = recordStore.lastErrorKey {
                Section {
                    Text(localization.text(errorKey))
                        .foregroundStyle(.red)
                }
            }
        }
        .peakScrollableSurface()
        .navigationTitle(localization.text(.recordBodyWeight))
        .peakInlineNavigationTitle()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(localization.text(.cancel)) { dismiss() }
            }
            SaveToolbar(canSave: validationMessage == nil) {
                guard let weight else { return }
                recordStore.addBodyWeight(measuredAt: measuredAt, weightKg: weight, note: note)
                dismiss()
            }
        }
    }
}
