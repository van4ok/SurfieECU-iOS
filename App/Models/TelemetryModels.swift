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
        "Сигнал запуска",
        "Кислородный датчик",
        "Сигнал разрежения",
        "Выход форсунки",
        "Выход бензонасоса",
        "Выход зажигания",
        "Дроссельная заслонка",
        "Разъем бензонасоса",
        "Производственная ошибка 1",
        "Производственная ошибка 2",
        "Производственная ошибка 3",
        "Производственная ошибка 4",
        "Производственная ошибка 5",
        "Производственная ошибка 6",
        "Производственная ошибка 7",
        "Производственная ошибка 8"
    ]
}

enum TelemetryParseError: Error, Equatable {
    case ignoredFragment
    case invalidHeader
    case incomplete
    case tooShort(Int)
}
