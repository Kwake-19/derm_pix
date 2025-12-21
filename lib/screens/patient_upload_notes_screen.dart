import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class PatientUploadNotesScreen extends StatelessWidget {
  final String dermatologistUid;

  const PatientUploadNotesScreen({
    super.key,
    required this.dermatologistUid,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    final uploadsRef = FirebaseDatabase.instance
        .ref('uploads/${user.uid}/$dermatologistUid');

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6F77),
        title: const Text("Doctor’s Notes"),
        centerTitle: true,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: uploadsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return _emptyState();
          }

          final raw = snapshot.data!.snapshot.value;
          if (raw is! Map) return _emptyState();

          final List<Map<String, dynamic>> uploads = [];

          raw.forEach((_, value) {
            if (value is Map) {
              uploads.add(Map<String, dynamic>.from(value));
            }
          });

          uploads.sort((a, b) {
            final aTime = a['uploadedAt'] ?? 0;
            final bTime = b['uploadedAt'] ?? 0;
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: uploads.length,
            itemBuilder: (context, index) {
              return _uploadCard(uploads[index]);
            },
          );
        },
      ),
    );
  }

  // ─────────────────────────
  // EMPTY STATE
  // ─────────────────────────
  Widget _emptyState() {
    return const Center(
      child: Text(
        "No uploads yet",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  // ─────────────────────────
  // UPLOAD CARD (READ-ONLY)
  // ─────────────────────────
  Widget _uploadCard(Map<String, dynamic> upload) {
    final String? imageUrl = upload['imageUrl'] as String?;
    final int? timestamp = upload['uploadedAt'] as int?;
    final String status = upload['status'] ?? 'pending';

    final String? noteText =
        upload['note'] != null && upload['note'] is Map
            ? upload['note']['text'] as String?
            : null;

    if (imageUrl == null || timestamp == null) {
      return const SizedBox();
    }

    final date = DateFormat.yMMMMd()
        .add_jm()
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp));

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(25, 0, 0, 0),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.network(
              imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // META ROW (FIXED)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 8),
                _statusChip(status),
              ],
            ),
          ),

          // NOTES
          if (status == 'reviewed' &&
              noteText != null &&
              noteText.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Doctor’s Note",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    noteText,
                    style: const TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────
  // STATUS CHIP
  // ─────────────────────────
  Widget _statusChip(String status) {
    final reviewed = status == 'reviewed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: reviewed
            ? const Color(0xFFE6F4EA)
            : const Color(0xFFFFFBEB),
        border: Border.all(
          color: reviewed ? Colors.green : Colors.orange,
        ),
      ),
      child: Text(
        reviewed ? "Reviewed" : "Pending",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: reviewed ? Colors.green : Colors.orange,
        ),
      ),
    );
  }
}
