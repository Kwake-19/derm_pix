import 'package:flutter/material.dart';

class PatientDetailScreen extends StatelessWidget {
  const PatientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patient Details")),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Patient A Progress",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: Text("Image 1 Placeholder")),
          ),
          const SizedBox(height: 12),

          Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: Text("Image 2 Placeholder")),
          ),
          const SizedBox(height: 12),

          Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: Text("Image 3 Placeholder")),
          ),
        ],
      ),
    );
  }
}
