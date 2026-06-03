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
    private var isFirstTelemetryPacket = true

    init(scanner: DeviceScanner, connector: DeviceConnector, telemetryService: TelemetryService) {
        self.scanner = scanner
        self.connector = connector
        self.telemetryService = telemetryService

        telemetryService.telemetryPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nextTelemetry in
                guard let self else { return }
                if isFirstTelemetryPacket {
                    telemetry = nextTelemetry
                    isFirstTelemetryPacket = false
                } else {
                    telemetry = telemetry.smoothed(toward: nextTelemetry, alpha: 0.35)
                }
                hasReceivedECUTelemetry = true
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
                resetTelemetryState()
                try await connector.connect(to: device)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func disconnect() {
        connector.disconnect()
        resetTelemetryState()
    }

    func readOnce() {
        do {
            try telemetryService.readOnce()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func resetTelemetryState() {
        telemetry = ECUTelemetry()
        hasReceivedECUTelemetry = false
        isFirstTelemetryPacket = true
    }
}
