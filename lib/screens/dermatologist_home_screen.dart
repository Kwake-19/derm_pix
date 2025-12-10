import 'package:flutter/material.dart';

class DermatologistHomeScreen extends StatelessWidget {
  const DermatologistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dermatologist Dashboard")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Patient A"),
            subtitle: const Text("3 recent uploads"),
            onTap: () {
              Navigator.pushNamed(context, '/patient-detail');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Patient B"),
            subtitle: const Text("1 recent upload"),
            onTap: () {
              Navigator.pushNamed(context, '/patient-detail');
            },
          ),
        ],
      ),
    );
  }
}
