import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DermatologistPatientScreen extends StatelessWidget {
  final String patientUid;

  const DermatologistPatientScreen({
    super.key,
    required this.patientUid,
  });

  Future<Map<String, dynamic>> _loadPatientProfile() async {
    final snapshot =
        await FirebaseDatabase.instance.ref("users/$patientUid").get();

    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6F77),
        title: const Text("Patient Details"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadPatientProfile(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final name = data["name"] ?? "Patient";

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _patientHeader(name),
                const SizedBox(height: 30),

                _actionCard(
                  icon: Icons.photo_library,
                  title: "View Uploads",
                  subtitle: "See submitted skin images",
                  onTap: () {
                    // TODO: navigate to uploads timeline
                  },
                ),

                _actionCard(
                  icon: Icons.note_alt,
                  title: "Clinical Notes",
                  subtitle: "Add observations & diagnosis",
                  onTap: () {
                    // TODO: notes feature
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _patientHeader(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Color(0xFF0B6F77),
            child: Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0B6F77)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

