import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

class PatientDermatologistScreen extends StatefulWidget {
  // ✅ THESE MUST EXIST
  final String dermatologistUid;
  final String dermatologistName;

  const PatientDermatologistScreen({
    super.key,
    required this.dermatologistUid,
    required this.dermatologistName,
  });

  @override
  State<PatientDermatologistScreen> createState() =>
      _PatientDermatologistScreenState();
}

class _PatientDermatologistScreenState
    extends State<PatientDermatologistScreen> {
  final String patientUid = FirebaseAuth.instance.currentUser!.uid;

  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _uploading = false;

  // ------------------
  // PICK IMAGE
  // ------------------
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  // ------------------
  // SAVE IMAGE (NO STORAGE)
  // ------------------
  Future<void> _saveUpload() async {
    if (_selectedImage == null) return;

    setState(() => _uploading = true);

    try {
      final uploadId = DateTime.now().millisecondsSinceEpoch.toString();

      await _db
          .child(
              "uploads/$patientUid/${widget.dermatologistUid}/$uploadId")
          .set({
        "localPath": _selectedImage!.path,
        "uploadedAt": ServerValue.timestamp,
      });

      if (!mounted) return;

      setState(() {
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image uploaded successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // ------------------
  // UI
  // ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6F77),
        elevation: 0,
        title: Text(
          widget.dermatologistName,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // ------------------
          // UPLOAD PREVIEW
          // ------------------
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _selectedImage == null
                  ? const Center(
                      child: Text(
                        "No image selected",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),

          // ------------------
          // BUTTONS
          // ------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton(
                icon: Icons.camera_alt,
                label: "Camera",
                onTap: () => _pickImage(ImageSource.camera),
              ),
              _actionButton(
                icon: Icons.photo_library,
                label: "Gallery",
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    (_selectedImage != null && !_uploading)
                        ? _saveUpload
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B6F77),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _uploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Upload Photo",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ------------------
          // PREVIOUS UPLOADS
          // ------------------
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _db
                  .child(
                      "uploads/$patientUid/${widget.dermatologistUid}")
                  .onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(
                    child: Text("No uploads yet"),
                  );
                }

                final uploads = Map<String, dynamic>.from(
                  snapshot.data!.snapshot.value as Map,
                );

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: uploads.values.map<Widget>((item) {
                    final path = item["localPath"];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(path),
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        IconButton(
          iconSize: 36,
          icon: Icon(icon, color: const Color(0xFF0B6F77)),
          onPressed: onTap,
        ),
        Text(label),
      ],
    );
  }
}

