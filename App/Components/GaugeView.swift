import SwiftUI

struct GaugeView: View {
    let value: Double
    let maximum: Double
    let title: String
    let unit: String

    private var isRPM: Bool { maximum > 1_000 }
    private var label: String { isRPM ? "RPM" : "SPEED" }
    private var segments: Int { isRPM ? 48 : 36 }
    private var warningStart: Int { isRPM ? 32 : 25 }
    private var dangerStart: Int { isRPM ? 40 : 31 }
    private var marks: [Int] { isRPM ? [0, 2_400, 4_800, 7_200, 9_600, 12_000] : [0, 20, 40, 60, 80, 100] }
    private var valueFontSize: CGFloat { isRPM ? 74 : 66 }
    private var unitFontSize: CGFloat { isRPM ? 20 : 18 }
    private var barHeight: CGFloat { isRPM ? 42 : 34 }
    private var verticalPadding: CGFloat { isRPM ? 22 : 18 }
    private var contentSpacing: CGFloat { isRPM ? 18 : 12 }

    private var progress: Double {
        guard maximum > 0 else { return 0 }
        return min(max(value / maximum, 0), 1)
    }

    private var activeSegments: Int {
        Int((progress * Double(segments)).rounded())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: contentSpacing) {
            header
            valueReadout
            SegmentedLevelBar(
                segments: segments,
                activeSegments: activeSegments,
                warningStart: warningStart,
                dangerStart: dangerStart
            )
            .frame(height: barHeight)
            scaleMarks
        }
        .padding(.horizontal, 22)
        .padding(.vertical, verticalPadding)
        .dashboardPanel(cornerRadius: 14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(unit)")
    }

    private var header: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.green)

            Spacer()

            if isRPM {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("LIMIT")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.red)
                    Text("10500")
                        .font(.system(size: 13, weight: .medium))
                        .monospacedDigit()
                        .foregroundStyle(.white.opacity(0.82))
                }
            }
        }
    }

    private var valueReadout: some View {
        HStack(alignment: .lastTextBaseline, spacing: 12) {
            Spacer(minLength: 0)
            Text(title)
                .font(.system(size: valueFontSize, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .animation(.easeOut(duration: 0.25), value: title)
            Text(unit.lowercased())
                .font(.system(size: unitFontSize, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.78))
            Spacer(minLength: 0)
        }
    }

    private var scaleMarks: some View {
        HStack(spacing: 0) {
            ForEach(marks, id: \.self) { mark in
                Text("\(mark)")
                    .font(.system(size: 12, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.72))
                    .frame(maxWidth: .infinity, alignment: markAlignment(for: mark))
            }
        }
    }

    private func markAlignment(for mark: Int) -> Alignment {
        if let first = marks.first, mark == first { return .leading }
        if let last = marks.last, mark == last { return .trailing }
        return .center
    }
}

private struct SegmentedLevelBar: View {
    let segments: Int
    let activeSegments: Int
    let warningStart: Int
    let dangerStart: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<segments, id: \.self) { index in
                SegmentCapsule(color: color(for: index), isActive: index < activeSegments)
            }
        }
        .animation(.easeOut(duration: 0.35), value: activeSegments)
    }

    private func color(for index: Int) -> Color {
        if index >= dangerStart { return .red }
        if index >= warningStart { return .yellow }
        return .green
    }
}

private struct SegmentCapsule: View {
    let color: Color
    let isActive: Bool

    var body: some View {
        Capsule()
            .fill(color)
            .opacity(isActive ? 1 : 0.16)
            .shadow(color: isActive ? color.opacity(0.35) : .clear, radius: 4, x: 0, y: 0)
            .frame(maxWidth: .infinity)
    }
}
