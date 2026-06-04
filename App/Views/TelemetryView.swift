import SwiftUI

struct TelemetryView: View {
    @EnvironmentObject private var bluetoothManager: BLEManager
    @EnvironmentObject private var viewModel: TelemetryViewModel
    @AppStorage("appLanguage") private var appLanguageRaw = AppLanguage.russian.rawValue
    @State private var showingDevices = false
    @State private var showingAbout = false
    @State private var showingDiagnostics = false

    private var telemetry: ECUTelemetry { viewModel.telemetry }
    private var language: AppLanguage { AppLanguage.from(appLanguageRaw) }
    private let metricColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
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
                    .padding(.vertical, 6)
                    .dashboardPanel()
                    .padding(.horizontal, 16)

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

                    bottomBar
                }
                .padding(.bottom, 14)
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
                        HStack(spacing: 8) {
                            Image(systemName: "link")
                            Circle()
                                .fill(statusColor)
                                .frame(width: 6, height: 6)
                            Text(toolbarConnectionText)
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                        }
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
            .sheet(isPresented: $showingDiagnostics) {
                NavigationStack {
                    ECUDiagnosticsView()
                }
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
        LazyVGrid(columns: metricColumns, spacing: 10) {
            MetricCard(
                title: L10n.oilPer100KM(language),
                value: number(telemetry.oilConsumptionPer100KM),
                unit: fuelVolumeUnit,
                iconName: "drop",
                iconColor: .green
            )
            MetricCard(
                title: L10n.oilPerHour(language),
                value: number(telemetry.oilConsumptionPerHour),
                unit: fuelVolumeUnit,
                iconName: "fuelpump",
                iconColor: .green
            )
            MetricCard(
                title: L10n.inletTemperature(language),
                value: number(telemetry.inletTemperature),
                unit: "\u{00B0}C",
                iconName: "thermometer.medium",
                iconColor: .red
            )
            MetricCard(
                title: L10n.engineTemperature(language),
                value: number(telemetry.engineTemperature),
                unit: "\u{00B0}C",
                iconName: "engine.combustion",
                iconColor: .green
            )
            MetricCard(
                title: "Y:",
                value: number(telemetry.y),
                unit: "Z",
                iconName: "bolt",
                iconColor: .green
            )
            MetricCard(
                title: L10n.throttle(language),
                value: number(telemetry.throttleValve),
                unit: voltageUnit,
                iconName: "slider.horizontal.3",
                iconColor: .blue
            )
        }
        .padding(.horizontal, 16)
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

    private var bottomBar: some View {
        HStack(spacing: 0) {
            bottomBarButton(icon: "waveform.path.ecg", title: dashboardTitle, isActive: true) {}
            bottomBarButton(icon: "chart.bar", title: dataTitle, isActive: false) {
                showingDiagnostics = true
            }
            bottomBarButton(icon: "gauge.with.dots.needle.50percent", title: diagnosticsTitle, isActive: false) {
                showingDiagnostics = true
            }
            bottomBarButton(icon: "exclamationmark.triangle", title: faultsTitle, isActive: false) {}
            bottomBarButton(icon: "ellipsis", title: moreTitle, isActive: false) {
                showingAbout = true
            }
        }
        .padding(6)
        .dashboardPanel(cornerRadius: 18)
        .padding(.horizontal, 16)
    }

    private func bottomBarButton(icon: String, title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .semibold))
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .foregroundStyle(isActive ? Color.green : .white.opacity(0.58))
            .background {
                if isActive {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.green.opacity(0.16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.green.opacity(0.55), lineWidth: 1)
                        }
                        .shadow(color: .green.opacity(0.25), radius: 8, x: 0, y: 0)
                }
            }
        }
        .buttonStyle(.plain)
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

    private func number(_ value: Double) -> String {
        String(format: "%.1f", value)
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

    private var toolbarConnectionText: String {
        if bluetoothManager.connectedDevice == nil {
            return language == .english ? "Offline" : "\u{041D}\u{0435}\u{0442}"
        }
        return language == .english ? "Connected" : "\u{041F}\u{043E}\u{0434}\u{043A}\u{043B}."
    }

    private var dashboardTitle: String {
        language == .english ? "Dash" : "\u{041F}\u{0440}\u{0438}\u{0431}."
    }

    private var dataTitle: String {
        language == .english ? "Data" : "\u{0414}\u{0430}\u{043D}\u{043D}."
    }

    private var diagnosticsTitle: String {
        language == .english ? "Diag" : "\u{0414}\u{0438}\u{0430}\u{0433}."
    }

    private var faultsTitle: String {
        language == .english ? "Faults" : "\u{041E}\u{0448}\u{0438}\u{0431}."
    }

    private var moreTitle: String {
        language == .english ? "More" : "\u{0415}\u{0449}\u{0435}"
    }
}
