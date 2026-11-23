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

/// 見出しと数値だけの表示。箱で囲まず、カードの中に直接置く。
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
        VStack(alignment: .leading, spacing: PeakSpacing.xxs) {
            Text(title)
                .font(PeakTypography.supporting)
                .foregroundStyle(PeakColor.textSecondary)
            Text(value)
                .font(PeakTypography.metric)
                .foregroundStyle(PeakColor.textPrimary)
            if let footnote {
                Text(footnote)
                    .font(PeakTypography.caption)
                    .foregroundStyle(PeakColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// 一覧が空のときの表示。
struct EmptyRecordView: View {
    let text: String
    let systemImage: String

    var body: some View {
        ContentUnavailableView(text, systemImage: systemImage)
            .frame(maxWidth: .infinity)
            .padding(.vertical, PeakSpacing.sm)
            .foregroundStyle(PeakColor.textSecondary)
    }
}

/// カード: 面（surface）、細い境界線、角丸 container。影は付けない（design-spec.md §5）。
struct PeakCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(PeakSpacing.md)
            .background(
                PeakColor.surface,
                in: RoundedRectangle(cornerRadius: PeakRadius.container, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: PeakRadius.container, style: .continuous)
                    .stroke(PeakColor.border, lineWidth: PeakSize.borderWidth)
            )
    }
}

/// 主要ボタン: accent の塗り。1画面に1つまで。
struct PeakPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PeakTypography.label)
            .foregroundStyle(isEnabled ? PeakColor.onAccent : PeakColor.textDisabled)
            .padding(.horizontal, PeakSpacing.md)
            .frame(minHeight: PeakSize.minTapTarget)
            .background(
                isEnabled ? PeakColor.accent : PeakColor.fillMuted,
                in: RoundedRectangle(cornerRadius: PeakRadius.element, style: .continuous)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

/// 補助ボタン: 下地（fillMuted）だけの控えめなボタン。
struct PeakSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PeakTypography.label)
            .foregroundStyle(PeakColor.textPrimary)
            .padding(.horizontal, PeakSpacing.md)
            .frame(minHeight: PeakSize.minTapTarget)
            .background(
                PeakColor.fillMuted,
                in: RoundedRectangle(cornerRadius: PeakRadius.element, style: .continuous)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

/// アイコンだけのボタン（追加の＋など）。見た目は小さく、タップ領域は44pt。
struct PeakIconButton: View {
    @Environment(\.isEnabled) private var isEnabled

    let systemImage: String
    let accessibilityLabel: String
    let action: () -> Void

    init(systemImage: String, accessibilityLabel: String, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(PeakTypography.heading)
                .foregroundStyle(isEnabled ? PeakColor.textPrimary : PeakColor.textDisabled)
                .frame(minWidth: PeakSize.minTapTarget, minHeight: PeakSize.minTapTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

/// 日を選んで記録を始めるときの日時。
/// 今日なら現在日時、過去の日ならその日の「今の時刻」にする（食事区分の推定を今の時刻に合わせるため）。
func recordEntryDate(on day: Date, now: Date = Date(), calendar: Calendar = .autoupdatingCurrent) -> Date {
    if calendar.isDate(day, inSameDayAs: now) {
        return now
    }
    let time = calendar.dateComponents([.hour, .minute], from: now)
    return calendar.date(
        bySettingHour: time.hour ?? 12,
        minute: time.minute ?? 0,
        second: 0,
        of: day
    ) ?? day
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
