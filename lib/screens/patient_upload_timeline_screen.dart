import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientUploadTimelineScreen extends StatelessWidget {
  final String dermatologistUid;

  const PatientUploadTimelineScreen({
    super.key,
    required this.dermatologistUid,
  });

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    final uploadsRef = FirebaseDatabase.instance
        .ref("uploads/${user.uid}/$dermatologistUid")
        .orderByChild("uploadedAt");

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6F77),
        title: const Text("Upload Timeline"),
        centerTitle: true,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: uploadsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {
            return _emptyState(context);
          }

          final Map<dynamic, dynamic> data =
              snapshot.data!.snapshot.value as Map;

          final uploads = data.entries.toList()
            ..sort((a, b) {
              final aTime = a.value["uploadedAt"] ?? 0;
              final bTime = b.value["uploadedAt"] ?? 0;
              return bTime.compareTo(aTime);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: uploads.length,
            itemBuilder: (context, index) {
              final uploadId = uploads[index].key.toString();
              final upload =
                  Map<String, dynamic>.from(uploads[index].value);

              return _uploadCard(
                context: context,
                upload: upload,
                uploadId: uploadId,
                patientUid: user.uid,
              );
            },
          );
        },
      ),
    );
  }

  // ─────────────────────────
  // EMPTY STATE
  // ─────────────────────────
  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 72,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              "No uploads yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your uploaded photos will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B6F77),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Upload a photo"),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────
  // UPLOAD CARD
  // ─────────────────────────
  Widget _uploadCard({
    required BuildContext context,
    required Map<String, dynamic> upload,
    required String uploadId,
    required String patientUid,
  }) {
    final String? imageUrl = upload["imageUrl"] as String?;
    final String? storagePath = upload["storagePath"] as String?;
    final int? timestamp = upload["uploadedAt"] as int?;

    final String date = timestamp != null
        ? DateFormat.yMMMMd()
            .add_jm()
            .format(DateTime.fromMillisecondsSinceEpoch(timestamp))
        : "Unknown date";

    if (imageUrl == null || storagePath == null) {
      return _brokenUploadCard(date);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(30, 0, 0, 0),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFF0B6F77),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B6F77),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDelete(
                        context,
                        patientUid,
                        uploadId,
                        storagePath,
                      );
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.check_circle,
                    color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  "Uploaded successfully",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────
  // CONFIRM DELETE
  // ─────────────────────────
  void _confirmDelete(
    BuildContext context,
    String patientUid,
    String uploadId,
    String storagePath,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete photo?"),
        content: const Text(
          "This photo will be permanently deleted. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteUpload(
                context,
                patientUid,
                uploadId,
                storagePath,
              );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────
  // DELETE LOGIC
  // ─────────────────────────
  Future<void> _deleteUpload(
    BuildContext context,
    String patientUid,
    String uploadId,
    String storagePath,
  ) async {
    try {
      // 1️⃣ Delete from Supabase Storage
      await _supabase.storage
          .from('patient-uploads')
          .remove([storagePath]);

      // 2️⃣ Delete metadata from Firebase
      await FirebaseDatabase.instance
          .ref('uploads/$patientUid/$dermatologistUid/$uploadId')
          .remove();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload deleted")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete failed: $e")),
        );
      }
    }
  }

  // ─────────────────────────
  // BROKEN CARD
  // ─────────────────────────
  Widget _brokenUploadCard(String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "This upload could not be loaded\n$date",
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
