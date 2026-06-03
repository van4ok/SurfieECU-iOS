import Foundation

enum RecoverabilityNote: String, Identifiable, CaseIterable {
    case login = "Login was present only as unused template text in the uni-app bundle. No login page route or cloud call is executed by the APK."
    case restAPI = "No business REST endpoints are called by the recovered Surfie screen. The bundle contains generic uniCloud SDK code only."
    case firmware = "No firmware update screen, OTA command, binary URL, or packet format was found in the APK."
    case fixedBLEUUID = "No fixed ECU service or characteristic UUID is hard-coded. Android enumerates every service and subscribes to every notify/indicate characteristic."
    case rideStatistics = "Ride statistics/history storage was not found. Android shows only live runtime and telemetry."

    var id: String { rawValue }
}
