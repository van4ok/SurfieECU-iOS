import SwiftUI

struct MetricRow: View {
    let title: String
    let value: String
    var iconName: String = "circle"
    var iconColor: Color = .green

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 22)
                .shadow(color: iconColor.opacity(0.35), radius: 5, x: 0, y: 0)

            Text(title)
                .foregroundStyle(.white.opacity(0.86))
                .lineLimit(2)
                .minimumScaleFactor(0.62)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 4)

            Text(value)
                .fontWeight(.semibold)
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .frame(minWidth: 62, alignment: .trailing)
        }
        .font(.system(size: 14))
        .padding(.vertical, 7)
    }
}
