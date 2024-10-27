import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class LockScreen extends StatefulWidget {
  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  List<BluetoothDevice> _bondedDevices = [];
  bool _isLocked = true;

  @override
  void initState() {
    super.initState();
    _getBondedDevices();
  }

  Future<void> _getBondedDevices() async {
    try {
      List<BluetoothDevice> bondedDevices =
      await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        _bondedDevices = bondedDevices;
      });
    } catch (e) {
      print("Error getting bonded devices: $e");
    }
  }

  Future<void> _toggleLock() async {
    try {
      if (_bondedDevices.any((device) => device.isConnected)) {
        // There is at least one connected device
        for (BluetoothDevice device in _bondedDevices) {
          if (device.isConnected) {
            String message = _isLocked ? '0' : '1';
            print("Sending $message signal to ${device.name}");
            await _sendMessage(device, message);
          }
        }
        setState(() {
          _isLocked = !_isLocked;
        });
      } else {
        print("No connected devices");
        // Handle the case when there are no connected devices
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _sendMessage(BluetoothDevice device, String message) async {
    try {
      if (!device.isConnected) {
        // Handle reconnection or display an error message
        print("Device not connected");
        return;
      }

      BluetoothConnection connection = await BluetoothConnection.toAddress(
        device.address,
      );

      Future.delayed(Duration(seconds: 5), () {
        if (connection.isConnected) {
          connection.finish();
        }
      });

      connection.input?.listen((Uint8List data) {
        print('Received data: ${utf8.decode(data)}');
      });

      connection.output.add(utf8.encode(message));
      await connection.output.allSent;
      await connection.close();
      showToast(_isLocked ? 'Lock signal sent' : 'Unlock signal sent');
    } catch (e) {
      print("Error sending message: $e");
      if (e.toString().contains("read failed")) {
        // Handle the read failed error, e.g., retry connection
      }
    }
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lock/Unlock'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
               Navigator.pushReplacementNamed(context, 'home');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isLocked ? Icons.lock : Icons.lock_open,
              size: 100,
              color: _isLocked ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleLock,
              style: ElevatedButton.styleFrom(
               // primary: _isLocked ? Colors.green : Colors.red,
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                _isLocked ? 'Unlock' : 'Lock',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LockScreen(),
  ));
}
