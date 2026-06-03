import SwiftUI

struct TelemetryView: View {
    @EnvironmentObject private var bluetoothManager: BLEManager
    @EnvironmentObject private var viewModel: TelemetryViewModel
    @State private var showingDevices = false
    @State private var showingAbout = false

    private var telemetry: ECUTelemetry { viewModel.telemetry }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text(telemetry.runtime)
                        .font(.system(size: 32, weight: .regular, design: .monospaced))
                        .padding(.top, 22)

                    HStack(alignment: .center, spacing: 16) {
                        GaugeView(
                            value: Double(telemetry.speed),
                            maximum: 100,
                            title: "\(telemetry.speed)",
                            unit: "km/h"
                        )
                        GaugeView(
                            value: Double(telemetry.rpm),
                            maximum: 12_000,
                            title: "\(telemetry.rpm)",
                            unit: "Rpm"
                        )
                    }

                    VStack(spacing: 3) {
                        MetricRow(title: "Расход топлива (100 км):", value: format(telemetry.oilConsumptionPer100KM, unit: "мл"))
                        MetricRow(title: "Расход топлива (1 час):", value: format(telemetry.oilConsumptionPerHour, unit: "мл"))
                        MetricRow(title: "Y:", value: format(telemetry.y, unit: "Z"))
                        MetricRow(title: "Дроссель:", value: format(telemetry.throttleValve, unit: "В"))
                        MetricRow(title: "Температура впуска:", value: format(telemetry.inletTemperature, unit: "C"))
                        MetricRow(title: "Температура двигателя:", value: format(telemetry.engineTemperature, unit: "C"))
                    }
                    .padding(.horizontal, 16)

                    VStack(spacing: 14) {
                        Text("Состояние системы")
                            .font(.system(size: 22, weight: .bold))
                        FaultGridView(
                            faults: telemetry.faultBits,
                            hasTelemetry: viewModel.hasReceivedECUTelemetry
                        )
                    }
                    .padding(.horizontal, 16)

                    connectionDetails
                }
                .padding(.bottom, 28)
            }
            .background(Color(red: 0.05, green: 0.055, blue: 0.06))
            .foregroundStyle(.white)
            .navigationTitle(AppConstants.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingDevices = true
                    } label: {
                        Image(systemName: "link")
                    }
                    .accessibilityLabel("Open device list")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAbout = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel("About")
                }
            }
            .toolbarBackground(Color(red: 0.2, green: 0.2, blue: 0.2), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showingDevices) {
                DeviceListPanel()
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var connectionDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let device = bluetoothManager.connectedDevice {
                Text("Connected: \(device.name)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Text(connectionStatus)
                    .font(.caption)
                    .foregroundStyle(statusColor)
            }

            if !bluetoothManager.activeServiceUUIDs.isEmpty {
                Text("Services: \(bluetoothManager.activeServiceUUIDs.map(\.uuidString).joined(separator: ", "))")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(3)
            }

            if !bluetoothManager.notifyCharacteristicUUIDs.isEmpty {
                Text("Notify: \(bluetoothManager.notifyCharacteristicUUIDs.map(\.uuidString).joined(separator: ", "))")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(3)
            }

            if bluetoothManager.notificationCount > 0 {
                Text("Notifications: \(bluetoothManager.notificationCount)")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.55))
                if let rpmDebugText {
                    Text(rpmDebugText)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.55))
                }
                Text("Last hex: \(shortHex(bluetoothManager.lastNotificationHex))")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.45))
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var connectionStatus: String {
        guard bluetoothManager.connectedDevice != nil else {
            return "Не подключено"
        }
        if viewModel.hasReceivedECUTelemetry {
            return "Получены данные Surfie ECU"
        }
        if bluetoothManager.notificationCount > 0 {
            return "Подключено, но пакеты не похожи на Surfie ECU"
        }
        if !bluetoothManager.notifyCharacteristicUUIDs.isEmpty {
            return "Подключено. Ожидание данных ECU"
        }
        return "Подключено. Notify-характеристика пока не найдена"
    }

    private var statusColor: Color {
        if viewModel.hasReceivedECUTelemetry {
            return .green
        }
        if bluetoothManager.notificationCount > 0 {
            return .orange
        }
        return .yellow
    }

    private func format(_ value: Double, unit: String) -> String {
        String(format: "%.1f %@", value, unit)
    }

    private var rpmDebugText: String? {
        let bytes = bytesFromHex(bluetoothManager.lastNotificationHex)
        guard bytes.count > 7 else {
            return nil
        }
        let rpm = Int(bytes[6]) * 256 + Int(bytes[7])
        return String(format: "RPM bytes: %02X %02X -> %d rpm", bytes[6], bytes[7], rpm)
    }

    private func shortHex(_ hex: String) -> String {
        guard hex.count > 64 else {
            return hex
        }
        let prefix = hex.prefix(64)
        return "\(prefix)..."
    }

    private func bytesFromHex(_ hex: String) -> [UInt8] {
        var result: [UInt8] = []
        var index = hex.startIndex
        while index < hex.endIndex {
            let next = hex.index(index, offsetBy: 2, limitedBy: hex.endIndex) ?? hex.endIndex
            if let byte = UInt8(hex[index..<next], radix: 16) {
                result.append(byte)
            }
            index = next
        }
        return result
    }
}
