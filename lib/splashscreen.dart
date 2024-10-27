import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a delay before navigating to the next page
    Timer(
      Duration(seconds: 4),
      () => Navigator.pushReplacementNamed(context, 'login'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background color to black
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace 'your_logo.png' with the path to your logo image
            Image.asset(
              'assets/logo.png',
              width: 150.0, // Adjust the width as needed
              height: 150.0, // Adjust the height as needed
            ),
            SizedBox(height: 20.0),
            CircularProgressIndicator(), // Add your preferred loading indicator
          ],
        ),
      ),
    );
  }
}
