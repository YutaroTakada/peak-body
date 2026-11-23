import SwiftUI

/// SCR-02 ダッシュボード。推移グラフ（FR-5.2）は design-spec.md §8 の PR5 で実装する。
/// それまでは何が入るかを1文だけ示す。
struct DashboardView: View {
    @EnvironmentObject private var localization: AppLocalization

    var body: some View {
        Text(localization.text(.dashboardPlaceholder))
            .font(PeakTypography.body)
            .foregroundStyle(PeakColor.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(PeakSpacing.md)
            .background(PeakColor.background)
            .navigationTitle(localization.text(.dashboard))
    }
}
