import Foundation

final class ECUPacketParser {
    private var receivedHex = ""

    func parse(_ data: Data) throws -> ECUTelemetry {
        let hex = data.map { String(format: "%02x", $0) }.joined()
        return try parse(hex: hex)
    }

    func parse(hex rawHex: String) throws -> ECUTelemetry {
        var hex = rawHex
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .lowercased()

        if hex.hasSuffix("0a") {
            hex.removeLast(2)
        }

        if (hex.count == 42 || hex.count == 40), hex.hasPrefix("aa") {
            receivedHex = hex
            throw TelemetryParseError.incomplete
        }

        if (hex.count == 24 || hex.count == 22), receivedHex.count == 40 {
            receivedHex += hex
            let bytes = bytesFromHex(receivedHex)
            receivedHex = ""
            return try parsePayload(bytes)
        }

        if (hex.count == 64 || hex.count == 62), hex.hasPrefix("aa") {
            let bytes = bytesFromHex(hex)
            receivedHex = ""
            return try parsePayload(bytes)
        }

        throw hex.hasPrefix("aa") ? TelemetryParseError.incomplete : TelemetryParseError.invalidHeader
    }

    private func parsePayload(_ bytes: [UInt8]) throws -> ECUTelemetry {
        guard bytes.count > 29 else {
            throw TelemetryParseError.tooShort(bytes.count)
        }

        let oilPerHour = integer([bytes[8], bytes[9]])
        let y = integer([bytes[13]])
        let oilPer100 = 255 * integer([bytes[10]]) * 255 + 255 * integer([bytes[11]]) + integer([bytes[12]])
        let throttle = integer([bytes[4], bytes[5]])
        let rpm = 256 * integer([bytes[6]]) + integer([bytes[7]])
        let speed = integer([bytes[16], bytes[17]])
        let runtimeSeconds = integer([bytes[19], bytes[20], bytes[21], bytes[22]])
        let status = bits([bytes[29]])
        let faults = bits([bytes[29], bytes[28]])
        let engineTemperature = integer([bytes[14]])
        let inletTemperature = integer([bytes[18]])

        return ECUTelemetry(
            oilConsumptionPer100KM: Double(oilPer100),
            oilConsumptionPerHour: Double(oilPerHour),
            y: Double(y),
            throttleValve: Double(throttle),
            inletTemperature: Double(inletTemperature),
            engineTemperature: Double(engineTemperature),
            speed: speed,
            rpm: rpm,
            runtime: formatDuration(runtimeSeconds),
            statusBits: status,
            faultBits: faults
        )
    }

    private func bytesFromHex(_ hex: String) -> [UInt8] {
        var bytes: [UInt8] = []
        var index = hex.startIndex
        while index < hex.endIndex {
            let next = hex.index(index, offsetBy: 2, limitedBy: hex.endIndex) ?? hex.endIndex
            let byteString = String(hex[index..<next])
            if let value = UInt8(byteString, radix: 16) {
                bytes.append(value)
            }
            index = next
        }
        return bytes
    }

    private func integer(_ bytes: [UInt8]) -> Int {
        bytes.reduce(0) { ($0 << 8) | Int($1) }
    }

    private func bits(_ bytes: [UInt8]) -> [Bool] {
        bytes.flatMap { byte in
            (0..<8).map { offset in
                let bit = 7 - offset
                return (byte & (1 << UInt8(bit))) != 0
            }
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
}
