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
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .frame(width: 48, height: 48)
                        .background(.thinMaterial, in: Circle())
                        .shadow(radius: 6, y: 2)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(localization.text(.settings))
                .foregroundStyle(PeakTheme.primaryText)
                .padding(.leading, 16)
                .padding(.bottom, 72)
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
