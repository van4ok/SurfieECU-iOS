import Foundation

struct BLEDiagnosticRecord: Identifiable, Equatable {
    enum Source: String {
        case notify
        case read
    }

    let id = UUID()
    let date: Date
    let source: Source
    let serviceUUID: String
    let characteristicUUID: String
    let length: Int
    let hex: String
    let looksLikeECUPacket: Bool
}
