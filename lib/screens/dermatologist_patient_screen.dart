import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DermatologistPatientScreen extends StatelessWidget {
  final String patientUid;
  final String patientName;

  const DermatologistPatientScreen({
    super.key,
    required this.patientUid,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    final DatabaseReference uploadsRef =
        FirebaseDatabase.instance.ref("uploads/$patientUid");

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),

      // 🔷 APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6F77),
        elevation: 0,
        title: Text(
          patientName,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // 🔷 BODY
      body: StreamBuilder<DatabaseEvent>(
        stream: uploadsRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {
            return const Center(
              child: Text(
                "No uploads yet",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final Map<String, dynamic> uploads =
              Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          final uploadEntries = uploads.entries.toList()
            ..sort(
              (a, b) =>
                  (b.value["uploadedAt"] ?? 0)
                      .compareTo(a.value["uploadedAt"] ?? 0),
            );

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: uploadEntries.length,
            itemBuilder: (context, index) {
              final upload = uploadEntries[index].value;
              final path = upload["localPath"];

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🖼 IMAGE
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.file(
                        File(path),
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // 📅 META
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: const [
                          Icon(Icons.photo_camera, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "Patient upload",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
