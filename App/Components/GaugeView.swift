import SwiftUI

struct GaugeView: View {
    let value: Double
    let maximum: Double
    let title: String
    let unit: String

    private var progress: Double {
        guard maximum > 0 else { return 0 }
        return min(max(value / maximum, 0), 1)
    }

    private var tint: Color {
        switch progress {
        case ..<0.75: .green
        case ..<0.9: .yellow
        default: .red
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.12, to: 0.88)
                .stroke(.white.opacity(0.14), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .rotationEffect(.degrees(90))

            Circle()
                .trim(from: 0.12, to: 0.12 + 0.76 * progress)
                .stroke(tint, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .rotationEffect(.degrees(90))
                .animation(.easeOut(duration: 0.35), value: progress)

            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 24, weight: .semibold))
                    .monospacedDigit()
                    .minimumScaleFactor(0.6)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.25), value: title)
                Text(unit)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.72))
            }
            .padding(.horizontal, 12)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(minWidth: 130, maxWidth: 180)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(unit)")
    }
}
