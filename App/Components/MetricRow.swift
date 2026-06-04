import SwiftUI

struct MetricRow: View {
    let title: String
    let value: String
    var iconName: String = "circle"
    var iconColor: Color = .green

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 24)
                .shadow(color: iconColor.opacity(0.35), radius: 5, x: 0, y: 0)

            Text(title)
                .foregroundStyle(.white.opacity(0.86))
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            Spacer(minLength: 8)

            Text(value)
                .fontWeight(.semibold)
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .font(.system(size: 15))
        .padding(.vertical, 8)
    }
}
