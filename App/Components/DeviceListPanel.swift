import SwiftUI

struct DeviceListPanel: View {
    @EnvironmentObject private var bluetoothManager: BLEManager
    @EnvironmentObject private var viewModel: TelemetryViewModel
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appLanguage") private var appLanguageRaw = AppLanguage.russian.rawValue

    private var language: AppLanguage { AppLanguage.from(appLanguageRaw) }

    var body: some View {
        NavigationStack {
            List {
                Section(sectionStatus) {
                    HStack {
                        Text(scanStatusTitle)
                        Spacer()
                        Text(bluetoothManager.isScanning ? discoveringTitle : stopTitle)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("bluetooth")
                        Spacer()
                        Text(String(describing: bluetoothManager.state))
                            .foregroundStyle(.secondary)
                    }
                }

                Section(devicesTitle) {
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
                                    Text(L10n.notSurfieDevice(language))
                                        .font(.caption2)
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(devicesTitle)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(closeTitle) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(bluetoothManager.isScanning ? stopTitle : scanTitle) {
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

    private var sectionStatus: String {
        switch language {
        case .english: "Status"
        case .russian: "\u{0421}\u{0442}\u{0430}\u{0442}\u{0443}\u{0441}"
        }
    }

    private var scanStatusTitle: String {
        switch language {
        case .english: "scan status"
        case .russian: "\u{0441}\u{0442}\u{0430}\u{0442}\u{0443}\u{0441} \u{043F}\u{043E}\u{0438}\u{0441}\u{043A}\u{0430}"
        }
    }

    private var discoveringTitle: String {
        switch language {
        case .english: "discovering"
        case .russian: "\u{043F}\u{043E}\u{0438}\u{0441}\u{043A}"
        }
    }

    private var stopTitle: String {
        switch language {
        case .english: "Stop"
        case .russian: "\u{0421}\u{0442}\u{043E}\u{043F}"
        }
    }

    private var scanTitle: String {
        switch language {
        case .english: "Scan"
        case .russian: "\u{041F}\u{043E}\u{0438}\u{0441}\u{043A}"
        }
    }

    private var devicesTitle: String {
        switch language {
        case .english: "Devices"
        case .russian: "\u{0423}\u{0441}\u{0442}\u{0440}\u{043E}\u{0439}\u{0441}\u{0442}\u{0432}\u{0430}"
        }
    }

    private var closeTitle: String {
        switch language {
        case .english: "Close"
        case .russian: "\u{0417}\u{0430}\u{043A}\u{0440}\u{044B}\u{0442}\u{044C}"
        }
    }
}
