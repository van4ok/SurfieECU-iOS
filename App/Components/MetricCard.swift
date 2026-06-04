import SwiftUI

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let iconName: String
    let iconColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 22)
                    .shadow(color: iconColor.opacity(0.45), radius: 5, x: 0, y: 0)

                Text(cleanTitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.80))
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }

            Spacer(minLength: 0)

            Text(value)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.58)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(unit)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.green)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(12)
        .frame(minHeight: 104)
        .dashboardPanel(cornerRadius: 10)
    }

    private var cleanTitle: String {
        title.trimmingCharacters(in: CharacterSet(charactersIn: ":"))
    }
}
