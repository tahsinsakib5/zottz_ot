// screens/device_scan_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceScanScreen extends StatefulWidget {
  final String userName;

  const DeviceScanScreen({Key? key, required this.userName}) : super(key: key);

  @override
  _DeviceScanScreenState createState() => _DeviceScanScreenState();
}

class _DeviceScanScreenState extends State<DeviceScanScreen> {
  List<BluetoothDevice> _devices = [];
  bool _scanning = false;
  late StreamSubscription<List<ScanResult>> _scanSubscription;
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _listenToBluetoothState();
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
    ].request();

    // Check if permissions are denied
    if (statuses[Permission.bluetooth]!.isDenied ||
        statuses[Permission.bluetoothConnect]!.isDenied ||
        statuses[Permission.bluetoothScan]!.isDenied) {
      await openAppSettings();
    }
  }

  void _listenToBluetoothState() {
    FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _adapterState = state;
      });
    });
  }

  void _scanDevices(bool enable) async {
    try {
      // Check Bluetooth state
      if (_adapterState != BluetoothAdapterState.on) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enable Bluetooth on your device')),
          );
        }
        setState(() {
          _scanning = false;
        });
        return;
      }

      setState(() {
        _scanning = enable;
      });

      if (enable) {
        _devices.clear();
        
        _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
          if (mounted) {
            for (ScanResult result in results) {
              // Only add devices with names and remove duplicates
              if (result.device.platformName.isNotEmpty && 
                  !_devices.any((device) => device.remoteId == result.device.remoteId)) {
                setState(() {
                  _devices.add(result.device);
                });
              }
            }
          }
        }, onError: (e) {
          print('Scan error: $e');
          if (mounted) {
            setState(() {
              _scanning = false;
            });
          }
        });

        // Start scan
        await FlutterBluePlus.startScan(
          timeout: Duration(seconds: 10),
          withServices: [],
        );
        
        // Auto stop after 10 seconds
        Future.delayed(Duration(seconds: 10), () {
          if (mounted && _scanning) {
            _scanDevices(false);
          }
        });
      } else {
        await FlutterBluePlus.stopScan();
        _scanSubscription.cancel();
      }
    } catch (e) {
      print('Error in _scanDevices: $e');
      if (mounted) {
        setState(() {
          _scanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning devices: $e')),
        );
      }
    }
  }

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
          IconButton(
            icon: _scanning ? Icon(Icons.stop) : Icon(Icons.search),
            onPressed: () => _scanning ? _scanDevices(false) : _scanDevices(true),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _scanDevices(false);
              setState(() {
                _devices.clear();
              });
              _scanDevices(true);
            },
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
          if (_scanning) LinearProgressIndicator(),
          Expanded(
            child: _devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bluetooth_disabled,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _scanning ? 'Scanning for devices...' : 'No devices found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _scanning ? 'Please wait...' : 'Tap the search icon to start scanning',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        if (!_scanning && _adapterState != BluetoothAdapterState.on)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: ElevatedButton(
                              onPressed: () {
                                FlutterBluePlus.turnOn();
                              },
                              child: const Text('Enable Bluetooth'),
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Icon(Icons.bluetooth),
                          title: Text(
                            device.platformName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(device.remoteId.toString()),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            _scanDevices(false);
                            // Navigate directly like in your working code
                            // Connection will be handled in the next screen
                            Navigator.pushNamed(
                              context,
                              '/led_sound',
                              arguments: {
                                'userName': widget.userName,
                                'device': device,
                              },
                            );
                          },
                        ),
                      );
                    },
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
      floatingActionButton: _devices.isNotEmpty && !_scanning
          ? FloatingActionButton(
              onPressed: () {
                _scanDevices(false);
                setState(() {
                  _devices.clear();
                });
                _scanDevices(true);
              },
              child: Icon(Icons.refresh),
              tooltip: 'Scan Again',
            )
          : null,
    );
  }

  @override
  void dispose() {
    _scanDevices(false);
    super.dispose();
  }
}