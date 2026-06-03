import SwiftUI

struct ECUDiagnosticsView: View {
    @EnvironmentObject private var bluetoothManager: BLEManager
    @State private var errorMessage: String?

    var body: some View {
        List {
            Section("Connection") {
                LabeledContent("Device", value: bluetoothManager.connectedDevice?.name ?? "Not connected")
                LabeledContent("Services", value: "\(bluetoothManager.activeServiceUUIDs.count)")
                LabeledContent("Notify", value: "\(bluetoothManager.notifyCharacteristicUUIDs.count)")
                LabeledContent("Records", value: "\(bluetoothManager.diagnosticRecords.count)")
            }

            Section("Actions") {
                Button("Read characteristics") {
                    do {
                        try bluetoothManager.readAllReadableCharacteristics()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
                .disabled(bluetoothManager.connectedDevice == nil)

                Button("Clear log", role: .destructive) {
                    bluetoothManager.clearDiagnosticRecords()
                }
                .disabled(bluetoothManager.diagnosticRecords.isEmpty)

                ShareLink(item: exportText) {
                    Label("Export BLE log", systemImage: "square.and.arrow.up")
                }
                .disabled(bluetoothManager.diagnosticRecords.isEmpty)
            }

            Section("Raw BLE records") {
                ForEach(bluetoothManager.diagnosticRecords.reversed()) { record in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(record.source.rawValue.uppercased())
                                .font(.caption.bold())
                                .foregroundStyle(record.source == .notify ? .blue : .green)
                            if record.looksLikeECUPacket {
                                Text("ECU-like")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.orange)
                            }
                            Spacer()
                            Text("\(record.length) bytes")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Text("\(record.serviceUUID) / \(record.characteristicUUID)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        Text(record.hex)
                            .font(.system(.caption2, design: .monospaced))
                            .lineLimit(4)
                            .textSelection(.enabled)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("ECU Diagnostics")
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var exportText: String {
        var lines = [
            "Surfie ECU BLE diagnostic log",
            "Device: \(bluetoothManager.connectedDevice?.name ?? "Not connected")",
            "Services: \(bluetoothManager.activeServiceUUIDs.map(\.uuidString).joined(separator: ", "))",
            "Notify: \(bluetoothManager.notifyCharacteristicUUIDs.map(\.uuidString).joined(separator: ", "))",
            "Records: \(bluetoothManager.diagnosticRecords.count)",
            ""
        ]

        let formatter = ISO8601DateFormatter()
        lines += bluetoothManager.diagnosticRecords.map { record in
            [
                formatter.string(from: record.date),
                record.source.rawValue,
                record.looksLikeECUPacket ? "ecu-like" : "raw",
                record.serviceUUID,
                record.characteristicUUID,
                "\(record.length)",
                record.hex
            ].joined(separator: "\t")
        }

        return lines.joined(separator: "\n")
    }
}
