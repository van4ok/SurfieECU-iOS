import Combine
import CoreBluetooth
import Foundation

enum BLEState: Equatable {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn

    init(_ state: CBManagerState) {
        switch state {
        case .unknown: self = .unknown
        case .resetting: self = .resetting
        case .unsupported: self = .unsupported
        case .unauthorized: self = .unauthorized
        case .poweredOff: self = .poweredOff
        case .poweredOn: self = .poweredOn
        @unknown default: self = .unknown
        }
    }
}

enum BLEError: Error, LocalizedError {
    case bluetoothUnavailable(BLEState)
    case missingPeripheral
    case missingWritableCharacteristic
    case connectionFailed(Error?)
    case disconnectedBeforeServices

    var errorDescription: String? {
        switch self {
        case .bluetoothUnavailable(let state):
            return "Bluetooth is not available: \(state)."
        case .missingPeripheral:
            return "No active ECU peripheral."
        case .missingWritableCharacteristic:
            return "No writable BLE characteristic was discovered."
        case .connectionFailed(let error):
            return error?.localizedDescription ?? "BLE connection failed."
        case .disconnectedBeforeServices:
            return "The BLE device disconnected before services were discovered."
        }
    }
}

@MainActor
final class BLEManager: NSObject, ObservableObject {
    @Published private(set) var state: BLEState = .unknown
    @Published private(set) var isScanning = false
    @Published private(set) var discoveredDevices: [DiscoveredDevice] = []
    @Published private(set) var connectedDevice: DiscoveredDevice?
    @Published private(set) var activeServiceUUIDs: [CBUUID] = []
    @Published private(set) var notifyCharacteristicUUIDs: [CBUUID] = []
    @Published private(set) var writableCharacteristicUUIDs: [CBUUID] = []
    @Published private(set) var notificationCount = 0
    @Published private(set) var lastNotificationHex = ""
    @Published private(set) var diagnosticRecords: [BLEDiagnosticRecord] = []

    let telemetryData = PassthroughSubject<Data, Never>()

    private var central: CBCentralManager!
    private var activePeripheral: CBPeripheral?
    private var writableCharacteristics: [(CBPeripheral, CBService, CBCharacteristic)] = []
    private var connectionContinuation: CheckedContinuation<Void, Error>?
    private var scanRequested = false
    private var scanTimeoutTask: Task<Void, Never>?

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() throws {
        scanRequested = true
        guard state == .poweredOn else {
            if state == .unknown || state == .resetting {
                return
            }
            throw BLEError.bluetoothUnavailable(state)
        }
        discoveredDevices.removeAll()
        isScanning = true
        central.scanForPeripherals(withServices: nil, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ])
        scheduleScanTimeout()
    }

    func stopScanning() {
        scanRequested = false
        stopScanningHardware()
    }

    private func stopScanningHardware() {
        scanTimeoutTask?.cancel()
        scanTimeoutTask = nil
        central.stopScan()
        isScanning = false
    }

    func connect(to device: DiscoveredDevice) async throws {
        stopScanning()
        if let activePeripheral {
            central.cancelPeripheralConnection(activePeripheral)
        }

        activePeripheral = device.peripheral
        device.peripheral.delegate = self
        connectedDevice = device
        activeServiceUUIDs = []
        notifyCharacteristicUUIDs = []
        writableCharacteristicUUIDs = []
        writableCharacteristics = []
        notificationCount = 0
        lastNotificationHex = ""
        diagnosticRecords = []

        try await withCheckedThrowingContinuation { continuation in
            connectionContinuation = continuation
            central.connect(device.peripheral, options: nil)
        }
    }

    func disconnect() {
        guard let activePeripheral else { return }
        central.cancelPeripheralConnection(activePeripheral)
        self.activePeripheral = nil
        connectedDevice = nil
        activeServiceUUIDs = []
        notifyCharacteristicUUIDs = []
        writableCharacteristicUUIDs = []
        writableCharacteristics = []
        notificationCount = 0
        lastNotificationHex = ""
    }

    func clearDiagnosticRecords() {
        diagnosticRecords = []
    }

    func write(_ data: Data) throws {
        guard !writableCharacteristics.isEmpty else {
            throw BLEError.missingWritableCharacteristic
        }
        for item in writableCharacteristics {
            let type: CBCharacteristicWriteType = item.2.properties.contains(.write) ? .withResponse : .withoutResponse
            item.0.writeValue(data, for: item.2, type: type)
        }
    }

    func readAllReadableCharacteristics() throws {
        guard let activePeripheral else {
            throw BLEError.missingPeripheral
        }
        for service in activePeripheral.services ?? [] {
            for characteristic in service.characteristics ?? [] where characteristic.properties.contains(.read) {
                activePeripheral.readValue(for: characteristic)
            }
        }
    }

    private func appendDevice(_ peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        let advertisedName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        let device = DiscoveredDevice(peripheral: peripheral, name: advertisedName ?? peripheral.name, rssi: rssi)
        if let index = discoveredDevices.firstIndex(where: { $0.id == device.id }) {
            discoveredDevices[index] = device
        } else {
            discoveredDevices.append(device)
        }
    }

    private func scheduleScanTimeout() {
        scanTimeoutTask?.cancel()
        scanTimeoutTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(10))
            guard !Task.isCancelled else { return }
            self?.stopScanning()
        }
    }
}

extension BLEManager: @preconcurrency CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        state = BLEState(central.state)
        if state != .poweredOn {
            stopScanningHardware()
            if state == .poweredOff || state == .unauthorized || state == .unsupported {
                scanRequested = false
            }
        } else if scanRequested && !isScanning {
            try? startScanning()
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        appendDevice(peripheral, advertisementData: advertisementData, rssi: RSSI)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionContinuation?.resume()
        connectionContinuation = nil
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionContinuation?.resume(throwing: BLEError.connectionFailed(error))
        connectionContinuation = nil
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let continuation = connectionContinuation {
            continuation.resume(throwing: error.map { BLEError.connectionFailed($0) } ?? BLEError.disconnectedBeforeServices)
            connectionContinuation = nil
        }
        activePeripheral = nil
        connectedDevice = nil
        activeServiceUUIDs = []
        notifyCharacteristicUUIDs = []
        writableCharacteristicUUIDs = []
        writableCharacteristics = []
        notificationCount = 0
        lastNotificationHex = ""
    }
}

extension BLEManager: @preconcurrency CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else { return }
        activeServiceUUIDs = peripheral.services?.map(\.uuid) ?? []
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else { return }
        for characteristic in service.characteristics ?? [] {
            if characteristic.properties.contains(.notify) || characteristic.properties.contains(.indicate) {
                peripheral.setNotifyValue(true, for: characteristic)
                if !notifyCharacteristicUUIDs.contains(characteristic.uuid) {
                    notifyCharacteristicUUIDs.append(characteristic.uuid)
                }
            }

            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                writableCharacteristics.append((peripheral, service, characteristic))
                if !writableCharacteristicUUIDs.contains(characteristic.uuid) {
                    writableCharacteristicUUIDs.append(characteristic.uuid)
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil, let value = characteristic.value else { return }
        let source: BLEDiagnosticRecord.Source = characteristic.isNotifying ? .notify : .read
        let hex = value.map { String(format: "%02x", $0) }.joined()
        appendDiagnosticRecord(
            source: source,
            serviceUUID: characteristic.service?.uuid.uuidString ?? "unknown",
            characteristicUUID: characteristic.uuid.uuidString,
            value: value,
            hex: hex
        )
        if source == .notify {
            notificationCount += 1
            lastNotificationHex = hex
        }
        telemetryData.send(value)
    }

    private func appendDiagnosticRecord(
        source: BLEDiagnosticRecord.Source,
        serviceUUID: String,
        characteristicUUID: String,
        value: Data,
        hex: String
    ) {
        let normalizedHex = hex.hasSuffix("0a") ? String(hex.dropLast(2)) : hex
        let record = BLEDiagnosticRecord(
            date: Date(),
            source: source,
            serviceUUID: serviceUUID,
            characteristicUUID: characteristicUUID,
            length: value.count,
            hex: hex,
            looksLikeECUPacket: normalizedHex.hasPrefix("aa") && [40, 42, 62, 64].contains(normalizedHex.count)
        )
        diagnosticRecords.append(record)
        if diagnosticRecords.count > 500 {
            diagnosticRecords.removeFirst(diagnosticRecords.count - 500)
        }
    }
}
