import 'package:flutter/material.dart';
import 'package:smartdoorlocksystem/login.dart';
import 'package:smartdoorlocksystem/splashscreen.dart';
import 'package:smartdoorlocksystem/register.dart';
import 'package:firebase_core/firebase_core.dart'; // Re-add Firebase import
import 'package:smartdoorlocksystem/forgetpass.dart';
import 'package:smartdoorlocksystem/home.dart';
import 'package:smartdoorlocksystem/lock.dart';
import 'package:smartdoorlocksystem/blue.dart';
import 'dart:developer';

// Import the file where UnlockScreen is defined

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    log('Firebase initialization error: $e');
  }
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash', // Set the initial route to the splash screen
      routes: {
        '/splash': (context) => SplashScreen(), // Define a route for 'splash'
        'register': (context) =>
            const MyRegister(), // Define a route for 'register'
        'login': (context) => const MyLogin(), // Define a route for 'login'
        'home': (context) => const HomeScreen(), // Define a route for 'home'
         'blue': (context) => BluetoothScreen(), // Define a route for 'blue'
        'hari': (context) => LockScreen(), // Define a route for 'lock'
        'forgetpass': (context) =>
            const MyForgetPassword(), // Add a route for 'forgetpass'
      },
    );
  }
}
