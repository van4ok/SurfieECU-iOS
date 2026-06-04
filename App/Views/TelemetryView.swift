import SwiftUI

struct TelemetryView: View {
    @EnvironmentObject private var bluetoothManager: BLEManager
    @EnvironmentObject private var viewModel: TelemetryViewModel
    @AppStorage("appLanguage") private var appLanguageRaw = AppLanguage.russian.rawValue
    @State private var showingDevices = false
    @State private var showingAbout = false

    private var telemetry: ECUTelemetry { viewModel.telemetry }
    private var language: AppLanguage { AppLanguage.from(appLanguageRaw) }
    private let metricColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    headerTimer

                    HStack(alignment: .center, spacing: 10) {
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
                    .padding(.horizontal, 8)

                    metricPanel

                    VStack(spacing: 14) {
                        Text(L10n.runningState(language))
                            .font(.system(size: 22, weight: .bold))
                            .overlay(alignment: .bottom) {
                                Capsule()
                                    .fill(Color.green)
                                    .frame(width: 44, height: 2)
                                    .offset(y: 8)
                            }
                        FaultGridView(
                            faults: telemetry.faultBits,
                            hasTelemetry: viewModel.hasReceivedECUTelemetry,
                            language: language
                        )
                    }
                    .padding(.horizontal, 16)

                    connectionDetails
                }
                .padding(.bottom, 28)
            }
            .background {
                dashboardBackground
            }
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
                        appLanguageRaw = language.toggled.rawValue
                    } label: {
                        Text(language.shortTitle)
                            .font(.caption.bold())
                            .monospaced()
                    }
                    .accessibilityLabel("Switch language")
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

    private var headerTimer: some View {
        VStack(spacing: 8) {
            Text(telemetry.runtime)
                .font(.system(size: 32, weight: .regular, design: .monospaced))
                .contentTransition(.numericText())

            HStack(spacing: 18) {
                NeonLine()
                Circle()
                    .fill(Color.green.opacity(viewModel.hasReceivedECUTelemetry ? 1 : 0.35))
                    .frame(width: 6, height: 6)
                    .shadow(color: .green.opacity(0.65), radius: 5)
                NeonLine()
            }
        }
        .padding(.top, 18)
    }

    private var metricPanel: some View {
        LazyVGrid(columns: metricColumns, spacing: 0) {
            MetricRow(
                title: L10n.oilPer100KM(language),
                value: format(telemetry.oilConsumptionPer100KM, unit: fuelVolumeUnit),
                iconName: "drop",
                iconColor: .green
            )
            MetricRow(
                title: L10n.inletTemperature(language),
                value: format(telemetry.inletTemperature, unit: "C"),
                iconName: "thermometer.medium",
                iconColor: .red
            )
            MetricRow(
                title: L10n.oilPerHour(language),
                value: format(telemetry.oilConsumptionPerHour, unit: fuelVolumeUnit),
                iconName: "fuelpump",
                iconColor: .green
            )
            MetricRow(
                title: L10n.engineTemperature(language),
                value: format(telemetry.engineTemperature, unit: "C"),
                iconName: "thermometer.high",
                iconColor: .orange
            )
            MetricRow(
                title: "Y:",
                value: format(telemetry.y, unit: "Z"),
                iconName: "bolt",
                iconColor: .green
            )
            MetricRow(
                title: L10n.throttle(language),
                value: format(telemetry.throttleValve, unit: voltageUnit),
                iconName: "slider.horizontal.3",
                iconColor: .blue
            )
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .dashboardPanel()
        .padding(.horizontal, 12)
    }

    private var connectionDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let device = bluetoothManager.connectedDevice {
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(L10n.connected(language)): \(device.name)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                        Text(connectionStatus)
                            .font(.caption)
                            .foregroundStyle(statusColor)
                    }
                    Spacer()
                    Button(L10n.disconnect(language)) {
                        viewModel.disconnect()
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
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
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var dashboardBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.01, green: 0.03, blue: 0.06),
                Color(red: 0.02, green: 0.055, blue: 0.09),
                Color(red: 0.04, green: 0.045, blue: 0.06)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay {
            RadialGradient(
                colors: [
                    Color.blue.opacity(0.20),
                    Color.clear
                ],
                center: .top,
                startRadius: 10,
                endRadius: 420
            )
        }
    }

    private var connectionStatus: String {
        guard bluetoothManager.connectedDevice != nil else {
            return L10n.notConnected(language)
        }
        if viewModel.hasReceivedECUTelemetry {
            return L10n.ecuDataReceived(language)
        }
        if bluetoothManager.notificationCount > 0 {
            return L10n.nonECUPackets(language)
        }
        if !bluetoothManager.notifyCharacteristicUUIDs.isEmpty {
            return L10n.waitingForECU(language)
        }
        return L10n.notifyNotFound(language)
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

    private var fuelVolumeUnit: String {
        switch language {
        case .english: "ml"
        case .russian: "\u{043C}\u{043B}"
        }
    }

    private var voltageUnit: String {
        switch language {
        case .english: "V"
        case .russian: "\u{0412}"
        }
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
