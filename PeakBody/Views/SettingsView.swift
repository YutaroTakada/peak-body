import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var localization: AppLocalization
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section(localization.text(.language)) {
                Picker(localization.text(.displayLanguage), selection: $localization.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName)
                            .tag(language)
                    }
                }
                .pickerStyle(.inline)
            }
        }
        .peakScrollableSurface()
        .navigationTitle(localization.text(.settings))
        .peakInlineNavigationTitle()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(localization.text(.close)) {
                    dismiss()
                }
            }
        }
    }
}

private enum SettingsSheet: Identifiable {
    case settings

    var id: String { "settings" }
}

struct SettingsAccessButtonModifier: ViewModifier {
    @EnvironmentObject private var localization: AppLocalization
    @State private var sheet: SettingsSheet?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottomLeading) {
                Button {
                    sheet = .settings
                } label: {
                    Image(systemName: "gearshape")
                        .font(PeakTypography.heading)
                        .foregroundStyle(PeakColor.textPrimary)
                        .frame(width: PeakSize.minTapTarget, height: PeakSize.minTapTarget)
                        .background(PeakColor.surfaceRaised, in: Circle())
                        .overlay(Circle().stroke(PeakColor.border, lineWidth: PeakSize.borderWidth))
                        .peakShadow(.med)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(localization.text(.settings))
                .padding(.leading, PeakSpacing.md)
                .padding(.bottom, PeakSpacing.md)
            }
            .sheet(item: $sheet) { _ in
                NavigationStack {
                    SettingsView()
                }
            }
    }
}

extension View {
    func settingsAccessButton() -> some View {
        modifier(SettingsAccessButtonModifier())
    }
}
