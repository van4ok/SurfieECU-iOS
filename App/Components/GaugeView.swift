import SwiftUI

struct GaugeView: View {
    let value: Double
    let maximum: Double
    let title: String
    let unit: String

    private let startAngle = 140.0
    private let endAngle = 400.0

    private var progress: Double {
        guard maximum > 0 else { return 0 }
        return min(max(value / maximum, 0), 1)
    }

    private var currentAngle: Double {
        startAngle + (endAngle - startAngle) * progress
    }

    private var majorMarks: [Double] {
        if maximum > 1_000 {
            return stride(from: 0.0, through: maximum, by: 2_400).map { $0 }
        }
        return stride(from: 0.0, through: maximum, by: 10).map { $0 }
    }

    private var minorMarks: [Double] {
        if maximum > 1_000 {
            return stride(from: 0.0, through: maximum, by: 600).map { $0 }
        }
        return stride(from: 0.0, through: maximum, by: 5).map { $0 }
    }

    private var zones: [(ClosedRange<Double>, Color)] {
        if maximum > 1_000 {
            return [
                (0.0...0.78, Color(red: 0.11, green: 0.82, blue: 0.36)),
                (0.78...0.86, Color(red: 1.0, green: 0.79, blue: 0.24)),
                (0.86...1.0, Color(red: 1.0, green: 0.25, blue: 0.36))
            ]
        }
        return [
            (0.0...0.70, Color(red: 0.11, green: 0.82, blue: 0.36)),
            (0.70...0.86, Color(red: 1.0, green: 0.79, blue: 0.24)),
            (0.86...1.0, Color(red: 1.0, green: 0.25, blue: 0.36))
        ]
    }

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let radius = size * 0.45

            ZStack {
                ForEach(Array(zones.enumerated()), id: \.offset) { _, zone in
                    GaugeArc(
                        startAngle: progressAngle(for: zone.0.lowerBound),
                        endAngle: progressAngle(for: zone.0.upperBound)
                    )
                    .stroke(zone.1, style: StrokeStyle(lineWidth: size * 0.07, lineCap: .butt))
                    .shadow(color: zone.1.opacity(0.22), radius: 3, x: 0, y: 0)
                }

                ForEach(minorMarks, id: \.self) { mark in
                    tick(
                        at: mark,
                        center: center,
                        radius: radius,
                        length: majorMarks.contains(mark) ? size * 0.075 : size * 0.045,
                        width: majorMarks.contains(mark) ? 2.0 : 1.2
                    )
                    .stroke(.white.opacity(majorMarks.contains(mark) ? 0.78 : 0.48), lineWidth: majorMarks.contains(mark) ? 1.4 : 0.9)
                }

                ForEach(majorMarks, id: \.self) { mark in
                    label(for: mark, center: center, radius: radius * 0.70)
                }

                needle(center: center, radius: radius * 0.63)
                    .fill(Color(red: 0.12, green: 0.84, blue: 0.35))
                    .shadow(color: .black.opacity(0.35), radius: 2, x: 0, y: 1)
                    .animation(.easeOut(duration: 0.35), value: currentAngle)

                Circle()
                    .fill(.white.opacity(0.88))
                    .frame(width: size * 0.045, height: size * 0.045)

                VStack(spacing: 5) {
                    Text(maximum > 1_000 ? "RPM" : "SPEED")
                        .font(.system(size: size * 0.075, weight: .medium))
                        .tracking(1.4)
                        .foregroundStyle(.white.opacity(0.42))
                        .offset(y: size * 0.05)

                    Text(title)
                        .font(.system(size: size * 0.28, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .animation(.easeOut(duration: 0.25), value: title)
                        .minimumScaleFactor(0.48)
                        .offset(y: size * 0.10)

                    Text(unit.lowercased())
                        .font(.system(size: size * 0.095, weight: .medium))
                        .foregroundStyle(Color(red: 0.13, green: 0.96, blue: 0.38))
                        .offset(y: size * 0.07)
                }

                footerPill(size: size)
                    .offset(y: size * 0.32)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(minWidth: 142, maxWidth: 178)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(unit)")
    }

    private func progressAngle(for progress: Double) -> Double {
        startAngle + (endAngle - startAngle) * progress
    }

    private func markAngle(for mark: Double) -> Double {
        progressAngle(for: min(max(mark / maximum, 0), 1))
    }

    private func point(center: CGPoint, radius: Double, angle: Double) -> CGPoint {
        let radians = angle * .pi / 180
        return CGPoint(
            x: center.x + cos(radians) * radius,
            y: center.y + sin(radians) * radius
        )
    }

    private func tick(at mark: Double, center: CGPoint, radius: Double, length: Double, width: Double) -> Path {
        let angle = markAngle(for: mark)
        let outer = point(center: center, radius: radius, angle: angle)
        let inner = point(center: center, radius: radius - length, angle: angle)
        var path = Path()
        path.move(to: outer)
        path.addLine(to: inner)
        return path
    }

    private func label(for mark: Double, center: CGPoint, radius: Double) -> some View {
        let position = point(center: center, radius: radius, angle: markAngle(for: mark))
        return Text(labelText(for: mark))
            .font(.system(size: maximum > 1_000 ? 13 : 14, weight: .medium))
            .monospacedDigit()
            .foregroundStyle(.white.opacity(0.88))
            .position(position)
    }

    private func labelText(for mark: Double) -> String {
        String(Int(mark))
    }

    private func needle(center: CGPoint, radius: Double) -> Path {
        let tip = point(center: center, radius: radius, angle: currentAngle)
        let left = point(center: center, radius: 8, angle: currentAngle + 115)
        let right = point(center: center, radius: 8, angle: currentAngle - 115)
        var path = Path()
        path.move(to: tip)
        path.addLine(to: left)
        path.addLine(to: right)
        path.closeSubpath()
        return path
    }

    private func footerPill(size: Double) -> some View {
        HStack(spacing: 6) {
            Image(systemName: maximum > 1_000 ? "engine.combustion" : "gauge.with.dots.needle.50percent")
                .font(.system(size: size * 0.07, weight: .semibold))
            Text(maximum > 1_000 ? "0-\(Int(maximum))" : "0-\(Int(maximum))")
                .font(.system(size: size * 0.06, weight: .medium))
                .monospacedDigit()
        }
        .foregroundStyle(Color.green)
        .padding(.horizontal, size * 0.08)
        .padding(.vertical, size * 0.035)
        .background {
            Capsule()
                .fill(Color.black.opacity(0.38))
                .overlay {
                    Capsule()
                        .stroke(.white.opacity(0.14), lineWidth: 1)
                }
        }
    }
}

private struct GaugeArc: Shape {
    let startAngle: Double
    let endAngle: Double

    func path(in rect: CGRect) -> Path {
        let size = min(rect.width, rect.height)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = size * 0.45
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: false
        )
        return path
    }
}
