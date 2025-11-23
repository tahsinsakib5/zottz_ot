// screens/device_scan_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zottz_ot/blutoth_service.dart';

class DeviceScanScreen extends StatefulWidget {
  final String userName;

  const DeviceScanScreen({Key? key, required this.userName}) : super(key: key);

  @override
  _DeviceScanScreenState createState() => _DeviceScanScreenState();
}

class _DeviceScanScreenState extends State<DeviceScanScreen> {
  List<ScanResult> _devices = [];
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _stateSubscription;
  StreamSubscription<bool>? _scanningSubscription;
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _listenToAdapterState();
    _listenToScanningState();
  }

  Future<void> _checkPermissions() async {
    // Request necessary permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,   
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
    ].request();

    // Check if all permissions are granted
    if (statuses[Permission.bluetooth]!.isDenied ||
        statuses[Permission.bluetoothConnect]!.isDenied ||
        statuses[Permission.bluetoothScan]!.isDenied) {
      await openAppSettings();
    }
  }

  void _listenToAdapterState() {
    _stateSubscription = FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _adapterState = state;
      });
      
      if (state == BluetoothAdapterState.on && !_isScanning) {
        _startScan();
      }
    });
  }

  void _listenToScanningState() {
    _scanningSubscription = FlutterBluePlus.isScanning.listen((isScanning) {
      setState(() {
        _isScanning = isScanning;
      });
    });
  }

  void _startScan() {
    if (_adapterState != BluetoothAdapterState.on) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable Bluetooth')),
      );
      return;
    }

    setState(() {
      _devices.clear();
    });

    // Listen to scan results
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          // Filter out devices with empty names and remove duplicates
          _devices = results
              .where((result) => result.device.platformName.isNotEmpty)
              .toSet() // Remove duplicates
              .toList();
        });
      }
    }, onError: (e) {
      print('Scan error: $e');
    });

    // Start scan
    FlutterBluePlus.startScan(
      withServices: [],
      timeout: const Duration(seconds: 10),
    );
  }

  void _stopScan() {
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
  }

  // Future<void> _connectToDevice(BluetoothDevice device) async {
  //   try {
  //     setState(() {
  //       _connectedDevice = device;
  //     });

  //     await device.connect(timeout: const Duration(seconds: 15), autoConnect: false);

  //     if (mounted) {
  //       // Navigate to LED & Sound selection screen
  //       Navigator.pushNamed(
  //         context,
  //         '/led_sound',
  //         arguments: {
  //           'userName': widget.userName,
  //           'device': device,
  //         },
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to connect: $e')),
  //       );
  //     }
  //     setState(() {
  //       _connectedDevice = null;
  //     });
  //   }
  // }

  Widget _buildBluetoothStateIndicator() {
    Color color;
    String text;

    switch (_adapterState) {
      case BluetoothAdapterState.on:
        color = Colors.green;
        text = 'Bluetooth: ON';
        break;
      case BluetoothAdapterState.off:
        color = Colors.red;
        text = 'Bluetooth: OFF';
        break;
      case BluetoothAdapterState.turningOn:
        color = Colors.orange;
        text = 'Bluetooth: Turning ON';
        break;
      case BluetoothAdapterState.turningOff:
        color = Colors.orange;
        text = 'Bluetooth: Turning OFF';
        break;
      default:
        color = Colors.grey;
        text = 'Bluetooth: Unknown';
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      color: color.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth, color: color, size: 16),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Devices'),
        actions: [
          if (_adapterState == BluetoothAdapterState.on)
            IconButton(
              icon: Icon(_isScanning ? Icons.stop : Icons.refresh),
              onPressed: _isScanning ? _stopScan : _startScan,
            ),
        ],
      ),
      body: Column(
        children: [
          _buildBluetoothStateIndicator(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select a Bluetooth device to connect',
              style: TextStyle(fontSize: 16),
            ),
          ),
          if (_adapterState != BluetoothAdapterState.on)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bluetooth_disabled, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Bluetooth is disabled'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        FlutterBluePlus.turnOn();
                      },
                      child: const Text('Enable Bluetooth'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: _devices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isScanning) const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            _isScanning 
                                ? 'Scanning for devices...' 
                                : 'No devices found\nTap refresh to scan again',
                            textAlign: TextAlign.center,
                          ),
                          if (!_isScanning)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: ElevatedButton(
                                onPressed: _startScan,
                                child: const Text('Start Scan'),
                              ),
                            ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        _stopScan();
                        await Future.delayed(const Duration(milliseconds: 500));
                        _startScan();
                      },
                      child: ListView.builder(
                        itemCount: _devices.length,
                        itemBuilder: (context, index) {
                          final result = _devices[index];
                          final device = result.device;
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.bluetooth),
                              title: Text(device.platformName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(device.remoteId.str),
                                  if (result.rssi != 0)
                                    Text('RSSI: ${result.rssi} dBm'),
                                ],
                              ),
                              trailing: device.connectionState == BluetoothConnectionState.connected
                                  ? const Icon(Icons.link, color: Colors.green)
                                  : const Icon(Icons.link_off, color: Colors.grey),
                              onTap: () => BluetoothManager().connectToDevice(device).then((_) {
                                Navigator.pushNamed(
                                  context,
                                  '/led_sound',
                                  arguments: {
                                    'userName': widget.userName,
                                    'device': device,
                                  },
                                );
                              }).catchError((e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to connect: $e')),
                                );
                              }
                            ),
                            ));
                        },
                      ),
                    ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/manual',
                  arguments: widget.userName,
                );
              },
              child: const Text('Manual Mode'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _stateSubscription?.cancel();
    _scanningSubscription?.cancel();
    _stopScan();
    super.dispose();
  }
}