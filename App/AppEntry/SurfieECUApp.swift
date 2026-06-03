import SwiftUI

@main
struct SurfieECUApp: App {
    @StateObject private var bluetoothManager: BLEManager
    @StateObject private var telemetryViewModel: TelemetryViewModel

    init() {
        let manager = BLEManager()
        _bluetoothManager = StateObject(wrappedValue: manager)
        _telemetryViewModel = StateObject(
            wrappedValue: TelemetryViewModel(
                scanner: DeviceScanner(manager: manager),
                connector: DeviceConnector(manager: manager),
                telemetryService: TelemetryService(manager: manager)
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            AppShellView()
                .environmentObject(bluetoothManager)
                .environmentObject(telemetryViewModel)
        }
    }
}
