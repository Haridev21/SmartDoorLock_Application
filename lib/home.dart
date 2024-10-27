import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:device_apps/device_apps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:io' show Platform;
void main() {
  runApp(const MyApp());


}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late ValueNotifier<bool> _refreshNotifier;
  List<String> connectedDevices = [];
  List<String> doorLog = []; // New list to store door log

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('  '),
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Door Log',
          ),
          /*         BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),*/
        ],
      ),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildDoorLogTab();
      default:
        return Container();
    }
  }

  Widget _buildHomeTab() {
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    PageController _pageController = PageController();
    int _currentPage = 0;
    List<String> _imagePaths = [
      'assets/dorrlock.png',
      'assets/ffff.png',
    ]; //adb shell am start -n de.kai_morich.serial_bluetooth_terminal/.MainActivity


    void _changePage() {
      _currentPage = (_currentPage + 1) % _imagePaths.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }


    // Auto swipe every 5 seconds and repeat forever
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      _changePage();
    });

    /*    void launchApp(String packageName) {
        try {
        DeviceApps.openApp(packageName);
        }
        catch (e) {
        print('Could not open app: $e');
          // Handle the error accordingly
       }
      }*/


    return Column(
      children: [
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: SizedBox(
            height: screenHeight / 3,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                _currentPage = index;
              },
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      _imagePaths[index],
                      width: 350,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(
          height: 20, // Add spacing between the Card and the buttons if needed
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity, // Set the width to fill the available space
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 5)],
            ),
            child: ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.greenAccent;
                    }
                    return Colors.red;
                  },
                ),
              ),
              onPressed: () {
                // Add the functionality to unlock here
                // For example, you can show a dialog or perform any unlock action
                //_showPinInputDialog(context);
                Navigator.pushReplacementNamed(context, 'hari');
                //discoverCharacteristics();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Unlock',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20, // Add spacing between the buttons if needed
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 5)],
            ),
            child: ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.greenAccent;
                    }
                    return Colors.red; // Default color
                  },
                ),
              ),
              onPressed: () {
                _showPinInputDialog(context);

              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Bluetooth Settings',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  void _showPinInputDialog(BuildContext context) {
    TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter PIN"),
          content: TextField(
            controller: pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter your PIN",
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String enteredPin = pinController.text;
                // Retrieve the user's UID from Firebase Authentication
                String userUID = FirebaseAuth.instance.currentUser!.uid;

                // Reference to the user's document in Firestore
                DocumentReference userDocRef =
                FirebaseFirestore.instance.collection('users').doc(userUID);

                // Fetch the user's document
                DocumentSnapshot userDocSnapshot = await userDocRef.get();

                // Check if the document exists
                if (userDocSnapshot.exists) {
                  // Access the data and retrieve the stored PIN
                  String storedPin = userDocSnapshot['pin'];

                  // Check if the entered PIN matches the stored PIN
                  if (enteredPin == storedPin) {
                    // PIN is correct, proceed with Bluetooth settings
                    //openAppChooser(context);
                    Navigator.pushReplacementNamed(context, 'blue');
                  } else {
                    // Incorrect PIN, show an error message
                    // You can customize this part based on your app's needs
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Incorrect PIN. Please try again."),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  // Handle the case where the user document doesn't exist
                  print('User document not found');
                }

                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }


  void launchApp(String packageName) {
    try {
      DeviceApps.openApp(packageName);
    } catch (e) {
      print('Could not open app: $e');
      // Handle the error accordingly
    }
  }


  Future<void> openAppChooser(BuildContext context) async {
    if (Platform.isAndroid) {
      try {
        List<Application> apps = await DeviceApps.getInstalledApplications();

        // Show installed apps in a dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Installed Apps'),
              content: SingleChildScrollView(
                child: Column(
                  children: apps
                      .map(
                        (app) =>
                        ListTile(
                          title: Text(app.appName),
                          onTap: () {
                            launchApp(app.packageName);
                            Navigator.of(context).pop();
                          },
                        ),
                  )
                      .toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        print('Could not retrieve installed apps: $e');
        // Handle the error accordingly
      }
    } else {
      // Handle other platforms if needed
      print('This feature is only supported on Android.');
    }
  }


  Widget _buildDoorLogTab() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Door Log',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Add your implementation for displaying door logs using doorLog list
          // For example, you can use ListView.builder
          Expanded(
            child: ListView.builder(
              itemCount: doorLog.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(doorLog[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Replace this method with your actual Bluetooth logic to receive messages at 9600 baud rate
  void updateDoorLog() {
    // Replace the simulation with your actual Bluetooth logic
    // For example, if you have a Bluetooth module, use its APIs to receive messages
    // BluetoothModule module = BluetoothModule();
    // String bluetoothMessage = module.receiveMessageAtBaudRate(9600);

    // Simulating received message for demonstration
    String bluetoothMessage = "Received Bluetooth message at 9600 baud rate";

    // Update doorLog with Bluetooth messages
    setState(() {
      doorLog.add(
          'Bluetooth: $bluetoothMessage'); // You can customize the format
    });
  }


}




