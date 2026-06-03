import SwiftUI

struct DeviceListPanel: View {
    @EnvironmentObject private var bluetoothManager: BLEManager
    @EnvironmentObject private var viewModel: TelemetryViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Status") {
                    HStack {
                        Text("scan status")
                        Spacer()
                        Text(bluetoothManager.isScanning ? "discovering" : "stop")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("bluetooth")
                        Spacer()
                        Text(String(describing: bluetoothManager.state))
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Devices") {
                    ForEach(bluetoothManager.discoveredDevices) { device in
                        Button {
                            viewModel.connect(to: device)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(device.name)
                                    .font(.headline)
                                Text(device.id.uuidString)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("RSSI \(device.rssi)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                if !isLikelySurfieDevice(device) {
                                    Text("\u{041D}\u{0435} \u{043F}\u{043E}\u{0445}\u{043E}\u{0436}\u{0435} \u{043D}\u{0430} Surfie ECU")
                                        .font(.caption2)
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Devices")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(bluetoothManager.isScanning ? "Stop" : "Scan") {
                        bluetoothManager.isScanning ? viewModel.stopDiscovery() : viewModel.startDiscovery()
                    }
                }
            }
            .onAppear {
                viewModel.startDiscovery()
            }
        }
    }

    private func isLikelySurfieDevice(_ device: DiscoveredDevice) -> Bool {
        let name = device.name.uppercased()
        return name.contains("SURFIE") || name.contains("ECU") || name.contains("MOTOR")
    }
}
