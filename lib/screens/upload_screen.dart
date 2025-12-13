import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image;
  bool _uploading = false;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance.ref();
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _uploadImage() async {
    final user = _auth.currentUser;
    if (user == null || _image == null) return;

    setState(() => _uploading = true);

    try {
      // 1️⃣ Check connection
      final connectionSnap =
          await _db.child("connections/${user.uid}").get();

      if (!connectionSnap.exists) {
        throw Exception("No dermatologist connected");
      }

      final doctorUid =
          connectionSnap.child("doctorUid").value.toString();

      // 2️⃣ Upload to Storage
      final uploadId = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage
          .ref("patient_uploads/${user.uid}/$uploadId.jpg");

      await ref.putFile(_image!);
      final imageUrl = await ref.getDownloadURL();

      // 3️⃣ Save metadata
      await _db.child("uploads/${user.uid}/$uploadId").set({
        "imageUrl": imageUrl,
        "doctorUid": doctorUid,
        "uploadedAt": ServerValue.timestamp,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo uploaded successfully")),
      );

      setState(() => _image = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04242A),
      appBar: AppBar(
        title: const Text("Upload Progress Photo"),
        backgroundColor: const Color(0xFF0B6F77),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image preview
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: _image == null
                  ? const Center(
                      child: Text(
                        "No image selected",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        _image!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // Buttons
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

            const Spacer(),

            // Upload button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                    (_image != null && !_uploading) ? _uploadImage : null,
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
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
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
          icon: Icon(icon, color: Colors.white),
          onPressed: onTap,
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

