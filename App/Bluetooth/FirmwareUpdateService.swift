import Foundation

@MainActor
final class FirmwareUpdateService {
    func beginUpdate() async throws {
        throw APIError.endpointUnavailable(
            "Firmware update is unavailable: the APK contains no OTA screen, endpoint, BLE command sequence, or firmware packet format."
        )
    }
}
