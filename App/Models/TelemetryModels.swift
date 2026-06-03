import Foundation

struct ECUTelemetry: Equatable {
    var oilConsumptionPer100KM: Double = 0
    var oilConsumptionPerHour: Double = 0
    var y: Double = 0
    var throttleValve: Double = 0
    var inletTemperature: Double = 0
    var engineTemperature: Double = 0
    var speed: Int = 0
    var rpm: Int = 0
    var runtime: String = "00:00:00"
    var statusBits: [Bool] = Array(repeating: false, count: 8)
    var faultBits: [Bool] = Array(repeating: false, count: 16)
}

enum TelemetryLabel {
    static let faults = [
        "trigger signal",
        "oxygen sensor",
        "negative pressure signal",
        "fuel injection output",
        "oil pump output",
        "ignition output",
        "throttle valve",
        "oil pump plug",
        "production fault 1",
        "production fault 2",
        "production fault 3",
        "production fault 4",
        "production fault 5",
        "production fault 6",
        "production fault 7",
        "production fault 8"
    ]
}

enum TelemetryParseError: Error, Equatable {
    case ignoredFragment
    case invalidHeader
    case incomplete
    case tooShort(Int)
}
