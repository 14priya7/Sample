import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'BLE Demo',
        theme: ThemeData(primarySwatch: Colors.red),
        home: const BleHome(),);
  }
}

  class BleHome extends StatefulWidget {
  const BleHome({super.key});
  @override
   State<BleHome> createState() => _BleHomeState();
  }

  class _BleHomeState extends State<BleHome> {
    List<ScanResult> scanResults = [];

    @override
    void initState() {
      super.initState();
      FlutterBluePlus.adapterState.listen((state) {
        if (state == BluetoothAdapterState.on) {
          debugPrint("Bluetooth ON");
        } else {
          debugPrint("Bluetooth OFF");
        }
      });
    }
    Future<void> startScan() async {
      scanResults.clear();
      setState(() {});
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          scanResults = results;
        });
      });
    }
    Future<void> stopScan() async {
      await FlutterBluePlus.stopScan();
    }
    Future<void> connectToDevice(BluetoothDevice device) async {
      await device.connect();
      debugPrint("Connected to ${device.remoteId}");

      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        debugPrint("Service: ${service.uuid}");
        for (var char in service.characteristics) {
          debugPrint("  Characteristic: ${char.uuid}");
        }
      }
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text("BLE Scan & Connect")),
        floatingActionButton: FloatingActionButton(
          onPressed: startScan,
          child: const Icon(Icons.search),
        ),
        body: ListView.builder(
          itemCount: scanResults.length,
          itemBuilder: (context, index) {
            final result = scanResults[index];
            final device = result.device;
            return ListTile(
              title: Text(device.platformName.isEmpty
                  ? "Unknown Device"
                  : device.platformName),
              subtitle: Text("ID: ${device.remoteId}"),
              trailing: ElevatedButton(
                onPressed: () => connectToDevice(device),
                child: const Text("Connect"),
              ),
            );
          },
        ),
      );
    }
  }



