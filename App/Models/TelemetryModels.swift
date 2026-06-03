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

enum TelemetryLabel {
    static let faults = [
        "\u{0421}\u{0438}\u{0433}\u{043D}\u{0430}\u{043B} \u{0437}\u{0430}\u{043F}\u{0443}\u{0441}\u{043A}\u{0430}",
        "\u{041A}\u{0438}\u{0441}\u{043B}\u{043E}\u{0440}\u{043E}\u{0434}\u{043D}\u{044B}\u{0439} \u{0434}\u{0430}\u{0442}\u{0447}\u{0438}\u{043A}",
        "\u{0421}\u{0438}\u{0433}\u{043D}\u{0430}\u{043B} \u{0440}\u{0430}\u{0437}\u{0440}\u{0435}\u{0436}\u{0435}\u{043D}\u{0438}\u{044F}",
        "\u{0412}\u{044B}\u{0445}\u{043E}\u{0434} \u{0444}\u{043E}\u{0440}\u{0441}\u{0443}\u{043D}\u{043A}\u{0438}",
        "\u{0412}\u{044B}\u{0445}\u{043E}\u{0434} \u{0431}\u{0435}\u{043D}\u{0437}\u{043E}\u{043D}\u{0430}\u{0441}\u{043E}\u{0441}\u{0430}",
        "\u{0412}\u{044B}\u{0445}\u{043E}\u{0434} \u{0437}\u{0430}\u{0436}\u{0438}\u{0433}\u{0430}\u{043D}\u{0438}\u{044F}",
        "\u{0414}\u{0440}\u{043E}\u{0441}\u{0441}\u{0435}\u{043B}\u{044C}\u{043D}\u{0430}\u{044F} \u{0437}\u{0430}\u{0441}\u{043B}\u{043E}\u{043D}\u{043A}\u{0430}",
        "\u{0420}\u{0430}\u{0437}\u{044A}\u{0435}\u{043C} \u{0431}\u{0435}\u{043D}\u{0437}\u{043E}\u{043D}\u{0430}\u{0441}\u{043E}\u{0441}\u{0430}",
        "\u{041F}\u{0440}\u{043E}\u{0438}\u{0437}\u{0432}\u{043E}\u{0434}\u{0441}\u{0442}\u{0432}\u{0435}\u{043D}\u{043D}\u{0430}\u{044F} \u{043E}\u{0448}\u{0438}\u{0431}\u{043A}\u{0430} 1",
        "\u{041F}\u{0440}\u{043E}\u{0438}\u{0437}\u{0432}\u{043E}\u{0434}\u{0441}\u{0442}\u{0432}\u{0435}\u{043D}\u{043D}\u{0430}\u{044F} \u{043E}\u{0448}\u{0438}\u{0431}\u{043A}\u{0430} 2",
        "\u{041F}\u{0440}\u{043E}\u{0438}\u{0437}\u{0432}\u{043E}\u{0434}\u{0441}\u{0442}\u{0432}\u{0435}\u{043D}\u{043D}\u{0430}\u{044F} \u{043E}\u{0448}\u{0438}\u{0431}\u{043A}\u{0430} 3",
        "\u{041F}\u{0440}\u{043E}\u{0438}\u{0437}\u{0432}\u{043E}\u{0434}\u{0441}\u{0442}\u{0432}\u{0435}\u{043D}\u{043D}\u{0430}\u{044F} \u{043E}\u{0448}\u{0438}\u{0431}\u{043A}\u{0430} 4",
        "\u{041F}\u{0440}\u{043E}\u{0438}\u{0437}\u{0432}\u{043E}\u{0434}\u{0441}\u{0442}\u{0432}\u{0435}\u{043D}\u{043D}\u{0430}\u{044F} \u{043E}\u{0448}\u{0438}\u{0431}\u{043A}\u{0430} 5",
        "\u{041F}\u{0440}\u{043E}\u{0438}\u{0437}\u{0432}\u{043E}\u{0434}\u{0441}\u{0442}\u{0432}\u{0435}\u{043D}\u{043D}\u{0430}\u{044F} \u{043E}\u{0448}\u{0438}\u{0431}\u{043A}\u{0430} 6",
        "\u{041F}\u{0440}\u{043E}\u{0438}\u{0437}\u{0432}\u{043E}\u{0434}\u{0441}\u{0442}\u{0432}\u{0435}\u{043D}\u{043D}\u{0430}\u{044F} \u{043E}\u{0448}\u{0438}\u{0431}\u{043A}\u{0430} 7",
        "\u{041F}\u{0440}\u{043E}\u{0438}\u{0437}\u{0432}\u{043E}\u{0434}\u{0441}\u{0442}\u{0432}\u{0435}\u{043D}\u{043D}\u{0430}\u{044F} \u{043E}\u{0448}\u{0438}\u{0431}\u{043A}\u{0430} 8"
    ]
}

enum TelemetryParseError: Error, Equatable {
    case ignoredFragment
    case invalidHeader
    case incomplete
    case tooShort(Int)
}
