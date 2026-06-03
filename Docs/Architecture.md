# iOS Architecture

```text
SurfieECUApp
  |
  +-- AppShellView
      |
      +-- TelemetryView
      |   +-- GaugeView
      |   +-- MetricRow
      |   +-- FaultGridView
      |   +-- DeviceListPanel
      |
      +-- AboutView

TelemetryViewModel
  |
  +-- DeviceScanner
  +-- DeviceConnector
  +-- TelemetryService
      |
      +-- BLEManager
          |
          +-- CBCentralManager
          +-- CBPeripheralDelegate
          +-- ECUPacketParser
```

## Data Flow

```text
BLE notification
  -> BLEManager.telemetryData
  -> TelemetryService.telemetryPublisher()
  -> ECUPacketParser
  -> ECUTelemetry
  -> TelemetryViewModel.telemetry
  -> TelemetryView
```

## Project Structure

```text
App/
├── Core/
├── Networking/
├── Bluetooth/
├── Models/
├── Services/
├── ViewModels/
├── Views/
├── Components/
├── Resources/
└── AppEntry/
```
