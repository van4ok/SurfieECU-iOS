import SwiftUI

struct FaultGridView: View {
    let faults: [Bool]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(Array(TelemetryLabel.faults.enumerated()), id: \.offset) { index, label in
                HStack(spacing: 8) {
                    Text(label)
                        .font(.system(size: 13))
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)

                    Spacer(minLength: 4)

                    Image(systemName: faultState(at: index) ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .foregroundStyle(faultState(at: index) ? .red : .green)
                }
                .frame(minHeight: 34)
            }
        }
    }

    private func faultState(at index: Int) -> Bool {
        faults.indices.contains(index) ? faults[index] : false
    }
}
