// services/bluetooth_manager.dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothManager {
  // HM-10 characteristics
  final String hm10ServiceUUID = "0000ffe0-0000-1000-8000-00805f9b34fb";
  final String hm10CharacteristicUUID = "0000ffe1-0000-1000-8000-00805f9b34fb";

  // Check if Bluetooth is available
  Future<bool> get isAvailable async {
    return await FlutterBluePlus.isAvailable;
  }

  // Check Bluetooth state
  Stream<BluetoothAdapterState> get adapterState {
    return FlutterBluePlus.adapterState;
  }

  // Scan for devices
  Stream<List<ScanResult>> scanDevices({Duration? timeout}) {
    // Start scan with proper parameters
    FlutterBluePlus.startScan(
      withServices: [], // Empty to scan all devices
      timeout: timeout ?? const Duration(seconds: 10),
    );
    
    return FlutterBluePlus.scanResults;
  }

  // Stop scanning
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  // Check if currently scanning
  Stream<bool> get isScanning {
    return FlutterBluePlus.isScanning;
  }

  // Connect to device
  Future<void> connectToDevice(BluetoothDevice device, {Duration? timeout}) async {
    try {
      // await device.connect(
      //   timeout: timeout ?? const Duration(seconds: 15),
      //   autoConnect: false,
      // );
    } catch (e) {
      throw Exception('Failed to connect to device: $e');
    }
  }

  // Disconnect from device
  Future<void> disconnectDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
    } catch (e) {
      throw Exception('Failed to disconnect from device: $e');
    }
  }

  // Check if device is connected
  bool isConnected(BluetoothDevice device) {
    return device.connectionState == BluetoothConnectionState.connected;
  }

  // Write to characteristic
  Future<void> writeCharacteristic(BluetoothDevice device, String data) async {
    try {
      if (!isConnected(device)) {
        throw Exception('Device is not connected');
      }

      List<BluetoothService> services = await device.discoverServices();
      
      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase() == hm10ServiceUUID) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() == hm10CharacteristicUUID) {
              List<int> bytes = data.codeUnits;
              await characteristic.write(bytes);
              return;
            }
          }
        }
      }
      throw Exception('Characteristic not found');
    } catch (e) {
      throw Exception('Failed to write characteristic: $e');
    }
  }

  // Listen to characteristic notifications
  Stream<List<int>> listenToCharacteristic(BluetoothDevice device) async* {
    try {
      if (!isConnected(device)) {
        throw Exception('Device is not connected');
      }

      List<BluetoothService> services = await device.discoverServices();
      
      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase() == hm10ServiceUUID) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() == hm10CharacteristicUUID) {
              // Enable notifications
              await characteristic.setNotifyValue(true);
              
              // Listen for value changes
              yield* characteristic.onValueReceived;
            }
          }
        }
      }
      throw Exception('Characteristic not found');
    } catch (e) {
      throw Exception('Failed to listen to characteristic: $e');
    }
  }

Future<List<BluetoothDevice>> get connectedDevices async {
  return FlutterBluePlus.connectedDevices;
}

  // Turn Bluetooth on
  Future<void> turnOnBluetooth() async {
    try {
      if (await FlutterBluePlus.isAvailable) {
        await FlutterBluePlus.turnOn();
      }
    } catch (e) {
      throw Exception('Failed to turn on Bluetooth: $e');
    }
  }

  // Turn Bluetooth off
  Future<void> turnOffBluetooth() async {
    try {
      if (await FlutterBluePlus.isAvailable) {
        await FlutterBluePlus.turnOff();
      }
    } catch (e) {
      throw Exception('Failed to turn off Bluetooth: $e');
    }
  }

  // Get services for a device
  Future<List<BluetoothService>> getServices(BluetoothDevice device) async {
    return await device.discoverServices();
  }

  // Find specific service
  BluetoothService? findService(List<BluetoothService> services, String serviceUUID) {
    for (var service in services) {
      if (service.uuid.toString().toLowerCase() == serviceUUID.toLowerCase()) {
        return service;
      }
    }
    return null;
  }

  // Find specific characteristic
  BluetoothCharacteristic? findCharacteristic(BluetoothService service, String characteristicUUID) {
    for (var characteristic in service.characteristics) {
      if (characteristic.uuid.toString().toLowerCase() == characteristicUUID.toLowerCase()) {
        return characteristic;
      }
    }
    return null;
  }
}