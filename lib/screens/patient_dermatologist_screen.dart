import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'upload_screen.dart'; // ✅ FIXED IMPORT
import 'patient_upload_timeline_screen.dart';


class PatientDermatologistScreen extends StatelessWidget {
  final String dermatologistUid;
  final String dermatologistName;

  const PatientDermatologistScreen({
    super.key,
    required this.dermatologistUid,
    required this.dermatologistName,
  });

  Future<Map<String, dynamic>> _loadDermProfile() async {
    final snapshot = await FirebaseDatabase.instance
        .ref("users/$dermatologistUid")
        .get();

    return snapshot.exists
        ? Map<String, dynamic>.from(snapshot.value as Map)
        : {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F7),

      // 🔷 APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6F77),
        elevation: 0,
        title: const Text("My Specialist"),
        centerTitle: true,
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadDermProfile(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final specialty =
              data["specialty"] ?? "Dermatology Specialist";

          return Column(
            children: [
              _profileHeader(dermatologistName, specialty),
              Expanded(child: _actions(context)),
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────
  // PROFILE HEADER
  // ─────────────────────────
  Widget _profileHeader(String name, String specialty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B6F77), Color(0xFF05363B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.verified_user,
              color: Color(0xFF0B6F77),
              size: 36,
            ),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                specialty,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────
  // ACTIONS
  // ─────────────────────────
  Widget _actions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Care Actions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // ⭐ PRIMARY ACTION
          _primaryAction(
            context,
            icon: Icons.photo_camera,
            title: "Upload Skin Photo",
            subtitle:
                "Send new progress photos to your dermatologist",
            onTap: () {
              // ✅ FIXED NAVIGATION
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UploadScreen(
                    dermatologistUid: dermatologistUid,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // SECONDARY ACTIONS
          _secondaryAction(
            icon: Icons.timeline,
            title: "Treatment Timeline",
            subtitle: "View previously uploaded photos",
            onTap: () {
              
               Navigator.push(
                  context,
                  MaterialPageRoute(
                   builder: (_) => PatientUploadTimelineScreen(
                     dermatologistUid: dermatologistUid,
                     ),
                  ),
              );
            },
          ),

          _secondaryAction(
            icon: Icons.info_outline,
            title: "Care Instructions",
            subtitle: "View notes from your dermatologist",
            onTap: () {
              // TODO: instructions screen
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────
  // UI COMPONENTS
  // ─────────────────────────
  Widget _primaryAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0B6F77),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(30, 0, 0, 0), // ✅ replaces withOpacity
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _secondaryAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Icon(icon, color: const Color(0xFF0B6F77)),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}


