import SwiftUI

struct FaultGridView: View {
    let faults: [Bool]
    let hasTelemetry: Bool
    let language: AppLanguage

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 12) {
            faultCard(indices: Array(0..<8))
            faultCard(indices: Array(8..<16))
        }
    }

    private func faultCard(indices: [Int]) -> some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 0) {
            ForEach(indices, id: \.self) { index in
                HStack(spacing: 9) {
                    Image(systemName: leadingIconName(at: index))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(leadingIconColor(at: index))
                        .frame(width: 22)

                    Text(L10n.faults(language)[index])
                        .font(.system(size: 14))
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .foregroundStyle(.white.opacity(0.88))

                    Spacer(minLength: 4)

                    Image(systemName: stateIconName(at: index))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(stateIconColor(at: index))
                }
                .frame(minHeight: 40)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(.white.opacity(0.07))
                        .frame(height: 1)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .dashboardPanel()
    }

    private func faultState(at index: Int) -> Bool {
        faults.indices.contains(index) ? faults[index] : false
    }

    private func stateIconName(at index: Int) -> String {
        guard hasTelemetry else {
            return "circle.fill"
        }
        return faultState(at: index) ? "xmark.circle.fill" : "checkmark.circle.fill"
    }

    private func stateIconColor(at index: Int) -> Color {
        guard hasTelemetry else {
            return .gray.opacity(0.75)
        }
        return faultState(at: index) ? .red : .green
    }

    private func leadingIconName(at index: Int) -> String {
        switch index {
        case 0: "engine.combustion"
        case 1: "sensor"
        case 2: "battery.25"
        case 3: "syringe"
        case 4: "fuelpump"
        case 5: "bolt.fill"
        case 6: "slider.horizontal.3"
        case 7: "switch.2"
        default: "exclamationmark.circle"
        }
    }

    private func leadingIconColor(at index: Int) -> Color {
        switch index {
        case 1, 3, 7: .green
        case 2: .yellow
        case 5: .green
        default: .green
        }
    }
}
