import 'package:flutter/material.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Profile")),
      body: Center(
        child: Text(
          "Patient Profile Coming Soon...",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
