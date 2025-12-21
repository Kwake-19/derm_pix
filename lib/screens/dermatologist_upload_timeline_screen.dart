import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import 'clinical_notes_screen.dart';

class DermatologistUploadTimelineScreen extends StatelessWidget {
  final String patientUid;
  final String dermatologistUid;

  const DermatologistUploadTimelineScreen({
    super.key,
    required this.patientUid,
    required this.dermatologistUid,
  });

  @override
  Widget build(BuildContext context) {
    final uploadsRef = FirebaseDatabase.instance
        .ref('uploads/$patientUid/$dermatologistUid');

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6F77),
        title: const Text('Patient Uploads'),
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

          // 🔒 Defensive check
          if (raw is! Map) {
            return _emptyState();
          }

          final List<Map<String, dynamic>> uploads = [];

          raw.forEach((uploadId, value) {
            if (value is Map) {
              uploads.add({
                'uploadId': uploadId,
                ...Map<String, dynamic>.from(value),
              });
            }
          });

          if (uploads.isEmpty) {
            return _emptyState();
          }

          // Newest first
          uploads.sort((a, b) {
            final aTime = a['uploadedAt'] ?? 0;
            final bTime = b['uploadedAt'] ?? 0;
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: uploads.length,
            itemBuilder: (context, index) {
              return _uploadCard(context, uploads[index]);
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
        'No uploads yet',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  // ─────────────────────────
  // UPLOAD CARD
  // ─────────────────────────
  Widget _uploadCard(
    BuildContext context,
    Map<String, dynamic> upload,
  ) {
    final String uploadId = upload['uploadId'];
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

    final date = DateFormat.yMMMEd()
        .add_jm()
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp));

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClinicalNotesScreen(
              imageUrl: imageUrl,
              uploadedAt: timestamp,
              patientName: "Patient",
              patientUid: patientUid,
              dermatologistUid: dermatologistUid,
              uploadId: uploadId,
              status: status,
            ),
          ),
        );
      },
      child: Container(
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
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 220,
                  child: Center(
                    child: Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
            ),

            // META ROW
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Color(0xFF0B6F77),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      date,
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _statusChip(status),
                ],
              ),
            ),

            // 📝 NOTE PREVIEW
            if (noteText != null && noteText.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.note_alt_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        noteText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
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
        color:
            reviewed ? const Color(0xFFE6F4EA) : const Color(0xFFFFFBEB),
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

