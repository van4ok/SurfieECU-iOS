import CoreBluetooth
import Foundation

struct DiscoveredDevice: Identifiable, Equatable {
    let id: UUID
    let peripheral: CBPeripheral
    let name: String
    let rssi: Int

    init(peripheral: CBPeripheral, name: String?, rssi: NSNumber) {
        self.id = peripheral.identifier
        self.peripheral = peripheral
        self.name = name?.isEmpty == false ? name! : "N/A"
        self.rssi = rssi.intValue
    }
}
