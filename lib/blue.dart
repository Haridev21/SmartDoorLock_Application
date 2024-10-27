import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Devices',
      home: BluetoothScreen(),
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> _pairedDevices = [];
  BluetoothConnection? _connection; // Make _connection nullable

  @override
  void initState() {
    super.initState();
    _getPairedDevices();
  }

  Future<void> _getPairedDevices() async {
    try {
      final bool isBluetoothEnabled =
          (await FlutterBluetoothSerial.instance.isEnabled) ?? false;
      if (isBluetoothEnabled) {
        List<BluetoothDevice> pairedDevices =
        await FlutterBluetoothSerial.instance.getBondedDevices();
        setState(() {
          _pairedDevices = pairedDevices;
        });
      } else {
        print("Bluetooth is not enabled");
        // Handle the case where Bluetooth is not enabled
      }
    } catch (e) {
      print("Error retrieving paired devices: $e");
      // Handle the error
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      final bool isBluetoothEnabled =
          (await FlutterBluetoothSerial.instance.isEnabled) ?? false;
      if (isBluetoothEnabled) {
        BluetoothConnection connection =
        await BluetoothConnection.toAddress(device.address);

        connection.input?.listen(
              (Uint8List data) {
            // Handle incoming data
          },
          onDone: () {
            // Handle when the connection is closed
            print("Connection closed");
          },
          onError: (error) {
            // Handle connection errors
            print("Connection error: $error");
          },
          cancelOnError: true,
        );

        setState(() {
          _connection = connection;
        });

        // Show toast message
        Fluttertoast.showToast(
          msg: "Connected to ${device.name}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // Do whatever you need with the connection here
      } else {
        print("Bluetooth is not enabled");
        // Handle the case where Bluetooth is not enabled
      }
    } catch (e) {
      print("Error connecting to device: $e");
      // Handle the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paired Bluetooth Devices'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle going back to the previous screen or action
            Navigator.pushReplacementNamed(context, 'home');
          },
        ),
      ),
      body: ListView.builder(
        itemCount: _pairedDevices.length,
        itemBuilder: (context, index) {
          BluetoothDevice device = _pairedDevices[index];
          return ListTile(
            title: Text(device.name ?? 'Unknown'),
            subtitle: Text(device.address ?? 'Unknown'),
            onTap: () {
              _connectToDevice(device);
            },
            trailing: _connection != null &&
                _connection!.isConnected // Check if _connection is not null and isConnected
                ? Icon(Icons.bluetooth_connected, color: Colors.blue)
                : null,
          );
        },
      ),
    );
  }
}
