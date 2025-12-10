import 'package:flutter/material.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Photo"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Later: open camera / gallery
          },
          child: const Text("Select Image"),
        ),
      ),
    );
  }
}
