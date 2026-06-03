import Foundation

@MainActor
final class DeviceConnector {
    private let manager: BLEManager

    init(manager: BLEManager) {
        self.manager = manager
    }

    func connect(to device: DiscoveredDevice) async throws {
        try await manager.connect(to: device)
    }

    func disconnect() {
        manager.disconnect()
    }
}
