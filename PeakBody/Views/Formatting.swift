import Foundation

enum PBFormat {
    private static let japaneseDateHeader: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter
    }()

    private static let englishDateHeader: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()

    private static let japaneseDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d HH:mm"
        return formatter
    }()

    private static let englishDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d, HH:mm"
        return formatter
    }()

    static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static func dateHeader(_ date: Date, language: AppLanguage) -> String {
        switch language {
        case .ja:
            return japaneseDateHeader.string(from: date)
        case .en:
            return englishDateHeader.string(from: date)
        }
    }

    static func dateTime(_ date: Date, language: AppLanguage) -> String {
        switch language {
        case .ja:
            return japaneseDateTime.string(from: date)
        case .en:
            return englishDateTime.string(from: date)
        }
    }

    static func number(_ value: Double, fractionDigits: Int = 0) -> String {
        value.formatted(.number.precision(.fractionLength(fractionDigits)))
    }

    static func weight(_ value: Double) -> String {
        "\(number(value, fractionDigits: 1))kg"
    }

    static func calories(_ value: Double) -> String {
        "\(number(value))kcal"
    }

    static func grams(_ value: Double) -> String {
        "\(number(value, fractionDigits: 1))g"
    }
}
