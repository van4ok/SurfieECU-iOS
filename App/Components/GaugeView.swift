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

    private var isRPM: Bool {
        maximum > 1_000
    }

    private var label: String {
        isRPM ? "RPM" : "SPEED"
    }

    private var segments: Int {
        isRPM ? 48 : 36
    }

    private var activeSegments: Int {
        Int((progress * Double(segments)).rounded())
    }

    private var marks: [Int] {
        if isRPM {
            return [0, 2_400, 4_800, 7_200, 9_600, 12_000]
        }
        return [0, 20, 40, 60, 80, 100]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: isRPM ? 18 : 12) {
            HStack(alignment: .top) {
                Text(label)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.green)

                Spacer()

                if isRPM {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("LIMIT")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.red)
                        Text("10500")
                            .font(.system(size: 13, weight: .medium))
                            .monospacedDigit()
                            .foregroundStyle(.white.opacity(0.82))
                    }
                }
            }

            HStack(alignment: .lastTextBaseline, spacing: 12) {
                Spacer(minLength: 0)
                Text(title)
                    .font(.system(size: isRPM ? 74 : 66, weight: .heavy, design: .rounded))
                    .italic()
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.25), value: title)
                Text(unit.lowercased())
                    .font(.system(size: isRPM ? 20 : 18, weight: .medium, design: .rounded))
                    .italic()
                    .foregroundStyle(.white.opacity(0.78))
                Spacer(minLength: 0)
            }

            SegmentedLevelBar(
                segments: segments,
                activeSegments: activeSegments,
                warningStart: isRPM ? 32 : 25,
                dangerStart: isRPM ? 40 : 31
            )
            .frame(height: isRPM ? 42 : 34)

            HStack {
                ForEach(marks, id: \.self) { mark in
                    Text("\(mark)")
                        .font(.system(size: 12, weight: .medium))
                        .monospacedDigit()
                        .foregroundStyle(.white.opacity(0.72))
                        .frame(maxWidth: .infinity, alignment: markAlignment(for: mark))
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, isRPM ? 22 : 18)
        .dashboardPanel(cornerRadius: 14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(unit)")
    }

    private func markAlignment(for mark: Int) -> Alignment {
        if let first = marks.first, mark == first {
            return .leading
        }
        if let last = marks.last, mark == last {
            return .trailing
        }
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
                Capsule()
                    .fill(fillColor(for: index))
                    .opacity(index < activeSegments ? 1 : 0.16)
                    .shadow(color: index < activeSegments ? fillColor(for: index).opacity(0.35) : .clear, radius: 4, x: 0, y: 0)
                    .frame(maxWidth: .infinity)
            }
        }
        .animation(.easeOut(duration: 0.35), value: activeSegments)
    }

    private func fillColor(for index: Int) -> Color {
        if index >= dangerStart {
            return .red
        }
        if index >= warningStart {
            return .yellow
        }
        return .green
    }
}
