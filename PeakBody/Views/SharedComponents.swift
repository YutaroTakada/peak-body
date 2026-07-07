import SwiftUI

enum PeakKeyboard {
    case decimal
    case number
}

extension View {
    @ViewBuilder
    func peakKeyboard(_ keyboard: PeakKeyboard) -> some View {
        #if os(iOS)
        switch keyboard {
        case .decimal:
            keyboardType(.decimalPad)
        case .number:
            keyboardType(.numberPad)
        }
        #else
        self
        #endif
    }

    @ViewBuilder
    func peakInlineNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}

struct SummaryMetricView: View {
    let title: String
    let value: String
    let footnote: String?

    init(_ title: String, value: String, footnote: String? = nil) {
        self.title = title
        self.value = value
        self.footnote = footnote
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(PeakTheme.secondaryText)
            Text(value)
                .font(.headline)
                .monospacedDigit()
                .foregroundStyle(PeakTheme.primaryText)
            if let footnote {
                Text(footnote)
                    .font(.caption2)
                    .foregroundStyle(PeakTheme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(PeakTheme.elevatedSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(PeakTheme.border, lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
    }
}

struct EmptyRecordView: View {
    let text: String
    let systemImage: String

    var body: some View {
        ContentUnavailableView(text, systemImage: systemImage)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(PeakTheme.secondaryText)
    }
}

struct SaveToolbar: ToolbarContent {
    @EnvironmentObject private var localization: AppLocalization

    let canSave: Bool
    let onSave: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button(localization.text(.save), action: onSave)
                .disabled(!canSave)
        }
    }
}
