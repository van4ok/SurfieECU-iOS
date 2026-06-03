import Combine
import Foundation

@MainActor
final class TelemetryService {
    private let manager: BLEManager
    private let parser = ECUPacketParser()

    init(manager: BLEManager) {
        self.manager = manager
    }

    func telemetryPublisher() -> AnyPublisher<ECUTelemetry, Never> {
        manager.telemetryData
            .compactMap { [parser] data in
                try? parser.parse(data)
            }
            .eraseToAnyPublisher()
    }

    func readOnce() throws {
        try manager.readAllReadableCharacteristics()
    }

    func writeASCII(_ text: String) throws {
        guard let data = text.data(using: .ascii) else { return }
        try manager.write(data)
    }
}
