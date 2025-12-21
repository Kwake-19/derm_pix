import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadScreen extends StatefulWidget {
  final String dermatologistUid;

  const UploadScreen({
    super.key,
    required this.dermatologistUid,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image;
  bool _uploading = false;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance.ref();
  final _picker = ImagePicker();

  final SupabaseClient _supabase = Supabase.instance.client;

  // ─────────────────────────
  // PICK IMAGE
  // ─────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (picked != null && mounted) {
      setState(() => _image = File(picked.path));
    }
  }

  // ─────────────────────────
  // UPLOAD IMAGE (SUPABASE)
  // ─────────────────────────
  Future<void> _uploadImage() async {
    final user = _auth.currentUser;
    if (user == null || _image == null) return;

    setState(() => _uploading = true);

    try {
      final patientUid = user.uid;
      final dermUid = widget.dermatologistUid;
      final uploadId =
          DateTime.now().millisecondsSinceEpoch.toString();

      // 📁 Storage path inside Supabase
      final storagePath =
          '$patientUid/$dermUid/$uploadId.jpg';

      // 1️⃣ Upload file to Supabase Storage
      await _supabase.storage
          .from('patient-uploads')
          .upload(
            storagePath,
            _image!,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      // 2️⃣ Generate signed URL (24h expiry)
      final signedUrl = await _supabase.storage
          .from('patient-uploads')
          .createSignedUrl(storagePath, 60 * 60 * 24);

      // 3️⃣ Save metadata to Firebase Realtime DB
      await _db
          .child('uploads/$patientUid/$dermUid/$uploadId')
          .set({
        'imageUrl': signedUrl,
        'storagePath': '$patientUid/$dermUid/$uploadId.jpg',
        'uploadedAt': ServerValue.timestamp,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo uploaded successfully'),
        ),
      );

      setState(() => _image = null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // ─────────────────────────
  // UI
  // ─────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04242A),
      appBar: AppBar(
        title: const Text('Upload Progress Photo'),
        backgroundColor: const Color(0xFF0B6F77),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 📷 IMAGE PREVIEW
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
                        'No image selected',
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

            // 📸 PICK BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                _actionButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),

            const Spacer(),

            // ⬆️ UPLOAD BUTTON
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
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Upload Photo',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────
  // ACTION BUTTON
  // ─────────────────────────
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
