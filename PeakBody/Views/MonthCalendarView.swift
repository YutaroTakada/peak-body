import SwiftUI

/// 月間カレンダー（SCR-01）。日を選ぶと `selectedDay` が変わる。
/// 記録の印は1色の小さな点で、位置で種類を分ける（左=体重、中=食事、右=筋トレ）。
struct MonthCalendarView: View {
    @EnvironmentObject private var localization: AppLocalization

    @Binding var selectedDay: Date
    @Binding var displayedMonth: Date
    let flags: [Date: DayRecordFlags]

    @ScaledMetric(relativeTo: .body) private var dayMarkerSize = PeakSize.calendarDayMarker
    private let calendar = Calendar.autoupdatingCurrent
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    init(selectedDay: Binding<Date>, displayedMonth: Binding<Date>, flags: [Date: DayRecordFlags]) {
        _selectedDay = selectedDay
        _displayedMonth = displayedMonth
        self.flags = flags
    }

    var body: some View {
        VStack(spacing: PeakSpacing.xs) {
            header
            weekdayRow
            LazyVGrid(columns: columns, spacing: PeakSpacing.xxs) {
                ForEach(Array(dayCells.enumerated()), id: \.offset) { _, day in
                    if let day {
                        dayCell(day)
                    } else {
                        Color.clear
                            .frame(minHeight: PeakSize.minTapTarget)
                            .accessibilityHidden(true)
                    }
                }
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }

    private var header: some View {
        HStack(spacing: PeakSpacing.xxs) {
            Text(PBFormat.monthTitle(displayedMonth, language: localization.language))
                .font(PeakTypography.title)
                .foregroundStyle(PeakColor.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: PeakSpacing.xs)

            if !isShowingToday {
                Button(localization.text(.today)) {
                    selectedDay = today
                    displayedMonth = startOfMonth(today)
                }
                .buttonStyle(PeakSecondaryButtonStyle())
            }

            PeakIconButton(systemImage: "chevron.left", accessibilityLabel: localization.text(.previousMonth)) {
                moveMonth(by: -1)
            }

            PeakIconButton(systemImage: "chevron.right", accessibilityLabel: localization.text(.nextMonth)) {
                moveMonth(by: 1)
            }
            .disabled(isCurrentMonth)
        }
    }

    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(orderedWeekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(PeakTypography.caption)
                    .foregroundStyle(PeakColor.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .accessibilityHidden(true)
    }

    private func dayCell(_ day: Date) -> some View {
        let isSelected = calendar.isDate(day, inSameDayAs: selectedDay)
        let isToday = calendar.isDate(day, inSameDayAs: today)
        let isFuture = day > today
        let dayFlags = flags[calendar.startOfDay(for: day)] ?? DayRecordFlags()

        return Button {
            selectedDay = day
        } label: {
            VStack(spacing: PeakSpacing.xxxs) {
                Text("\(calendar.component(.day, from: day))")
                    .font(PeakTypography.body)
                    .fontWeight(isToday || isSelected ? .semibold : .regular)
                    .monospacedDigit()
                    .foregroundStyle(dayTextColor(isSelected: isSelected, isFuture: isFuture))
                    .frame(width: dayMarkerSize, height: dayMarkerSize)
                    .background {
                        if isSelected {
                            Circle().fill(PeakColor.accent)
                        } else if isToday {
                            Circle().stroke(PeakColor.borderEmphasized, lineWidth: PeakSize.borderWidth)
                        }
                    }

                RecordDots(flags: dayFlags)
            }
            .frame(maxWidth: .infinity, minHeight: PeakSize.minTapTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
        .accessibilityLabel(accessibilityLabel(for: day, flags: dayFlags))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func dayTextColor(isSelected: Bool, isFuture: Bool) -> Color {
        if isSelected { return PeakColor.onAccent }
        if isFuture { return PeakColor.textDisabled }
        return PeakColor.textPrimary
    }

    private func accessibilityLabel(for day: Date, flags: DayRecordFlags) -> String {
        var kinds: [String] = []
        if flags.hasBodyWeight { kinds.append(localization.text(.bodyWeight)) }
        if flags.hasMeal { kinds.append(localization.text(.meal)) }
        if flags.hasWorkout { kinds.append(localization.text(.workout)) }
        let date = PBFormat.dateHeader(day, language: localization.language)
        let records = kinds.isEmpty
            ? localization.text(.noRecords)
            : localization.text(.recordsExist, kinds.joined(separator: localization.text(.listSeparator)))
        let separator = localization.language == .ja ? "、" : ", "
        return date + separator + records
    }

    // MARK: - 日付の計算

    private var today: Date {
        calendar.startOfDay(for: Date())
    }

    private var isCurrentMonth: Bool {
        calendar.isDate(displayedMonth, equalTo: today, toGranularity: .month)
    }

    private var isShowingToday: Bool {
        isCurrentMonth && calendar.isDate(selectedDay, inSameDayAs: today)
    }

    private func startOfMonth(_ date: Date) -> Date {
        calendar.dateInterval(of: .month, for: date)?.start ?? calendar.startOfDay(for: date)
    }

    private func moveMonth(by value: Int) {
        guard let moved = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        let start = startOfMonth(moved)
        guard start <= today else { return }
        displayedMonth = start
    }

    /// 週の開始曜日（端末設定）に合わせて並べた曜日の記号。
    private var orderedWeekdaySymbols: [String] {
        let symbols = PBFormat.veryShortWeekdaySymbols(language: localization.language)
        let shift = calendar.firstWeekday - 1
        return Array(symbols[shift...] + symbols[..<shift])
    }

    /// 月の日付を7列に並べるための配列。月初の前の空きは nil。
    private var dayCells: [Date?] {
        let monthStart = startOfMonth(displayedMonth)
        guard let dayRange = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }
        let leading = (calendar.component(.weekday, from: monthStart) - calendar.firstWeekday + 7) % 7
        let days: [Date?] = dayRange.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart)
        }
        return Array(repeating: nil, count: leading) + days
    }
}

/// 記録の印。3つの位置を固定し、記録がある位置だけ点を出す（色だけに頼らない）。
private struct RecordDots: View {
    let flags: DayRecordFlags

    var body: some View {
        HStack(spacing: PeakSpacing.xxxs) {
            dot(flags.hasBodyWeight)
            dot(flags.hasMeal)
            dot(flags.hasWorkout)
        }
        .accessibilityHidden(true)
    }

    private func dot(_ isOn: Bool) -> some View {
        Circle()
            .fill(isOn ? PeakColor.textSecondary : Color.clear)
            .frame(width: PeakSize.recordDot, height: PeakSize.recordDot)
    }
}
