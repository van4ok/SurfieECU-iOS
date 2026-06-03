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
                        MetricRow(title: "oil consumption (100/KM):", value: format(telemetry.oilConsumptionPer100KM, unit: "ml"))
                        MetricRow(title: "oil consumption (1/H):", value: format(telemetry.oilConsumptionPerHour, unit: "ml"))
                        MetricRow(title: "Y:", value: format(telemetry.y, unit: "Z"))
                        MetricRow(title: "throttle valve:", value: format(telemetry.throttleValve, unit: "V"))
                        MetricRow(title: "inlet temperature:", value: format(telemetry.inletTemperature, unit: "C"))
                        MetricRow(title: "engine temperature:", value: format(telemetry.engineTemperature, unit: "C"))
                    }
                    .padding(.horizontal, 16)

                    VStack(spacing: 14) {
                        Text("running state")
                            .font(.system(size: 22, weight: .bold))
                        FaultGridView(faults: telemetry.faultBits)
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
            }

            if !bluetoothManager.activeServiceUUIDs.isEmpty {
                Text("Services: \(bluetoothManager.activeServiceUUIDs.map(\.uuidString).joined(separator: ", "))")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(3)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func format(_ value: Double, unit: String) -> String {
        String(format: "%.1f %@", value, unit)
    }
}
