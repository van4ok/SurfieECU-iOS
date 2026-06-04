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

    func smoothed(toward target: ECUTelemetry, alpha: Double) -> ECUTelemetry {
        let clampedAlpha = min(max(alpha, 0), 1)

        func smooth(_ current: Double, _ next: Double) -> Double {
            current + (next - current) * clampedAlpha
        }

        func smoothInt(_ current: Int, _ next: Int) -> Int {
            Int(round(smooth(Double(current), Double(next))))
        }

        return ECUTelemetry(
            oilConsumptionPer100KM: smooth(oilConsumptionPer100KM, target.oilConsumptionPer100KM),
            oilConsumptionPerHour: smooth(oilConsumptionPerHour, target.oilConsumptionPerHour),
            y: smooth(y, target.y),
            throttleValve: smooth(throttleValve, target.throttleValve),
            inletTemperature: smooth(inletTemperature, target.inletTemperature),
            engineTemperature: smooth(engineTemperature, target.engineTemperature),
            speed: smoothInt(speed, target.speed),
            rpm: smoothInt(rpm, target.rpm),
            runtime: target.runtime,
            statusBits: target.statusBits,
            faultBits: target.faultBits
        )
    }
}

enum TelemetryParseError: Error, Equatable {
    case ignoredFragment
    case invalidHeader
    case incomplete
    case tooShort(Int)
}
