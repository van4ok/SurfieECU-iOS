import Combine
import Foundation

@MainActor
final class TelemetryViewModel: ObservableObject {
    @Published private(set) var telemetry = ECUTelemetry()
    @Published private(set) var hasReceivedECUTelemetry = false
    @Published var errorMessage: String?

    private let scanner: DeviceScanner
    private let connector: DeviceConnector
    private let telemetryService: TelemetryService
    private var cancellables: Set<AnyCancellable> = []

    init(scanner: DeviceScanner, connector: DeviceConnector, telemetryService: TelemetryService) {
        self.scanner = scanner
        self.connector = connector
        self.telemetryService = telemetryService

        telemetryService.telemetryPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] telemetry in
                self?.telemetry = telemetry
                self?.hasReceivedECUTelemetry = true
            }
            .store(in: &cancellables)
    }

    func startDiscovery() {
        do {
            try scanner.start()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stopDiscovery() {
        scanner.stop()
    }

    func connect(to device: DiscoveredDevice) {
        Task {
            do {
                hasReceivedECUTelemetry = false
                try await connector.connect(to: device)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func disconnect() {
        connector.disconnect()
    }

    func readOnce() {
        do {
            try telemetryService.readOnce()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
