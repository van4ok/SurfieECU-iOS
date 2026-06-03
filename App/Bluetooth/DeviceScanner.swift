import Foundation

@MainActor
final class DeviceScanner {
    private let manager: BLEManager

    init(manager: BLEManager) {
        self.manager = manager
    }

    func start() throws {
        try manager.startScanning()
    }

    func stop() {
        manager.stopScanning()
    }
}
