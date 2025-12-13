import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DermatologistProfileScreen extends StatefulWidget {
  const DermatologistProfileScreen({super.key});

  @override
  State<DermatologistProfileScreen> createState() =>
      _DermatologistProfileScreenState();
}

class _DermatologistProfileScreenState
    extends State<DermatologistProfileScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // ------------------
  // LOAD PROFILE
  // ------------------
  Future<Map<String, dynamic>> _loadProfile() async {
    final snapshot =
        await FirebaseDatabase.instance.ref("users/$uid").get();

    if (!snapshot.exists) {
      throw Exception("Profile not found");
    }

    return Map<String, dynamic>.from(
      snapshot.value as Map<dynamic, dynamic>,
    );
  }

  // ------------------
  // LOGOUT
  // ------------------
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
  }

  // ------------------
  // UI
  // ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔷 DARK APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6F77),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B6F77), Color(0xFF04242A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: FutureBuilder<Map<String, dynamic>>(
            future: _loadProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Failed to load profile",
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              final data = snapshot.data!;
              final name = data["name"] ?? "Dermatologist";
              final email = data["email"] ?? "-";
              final specialty = data["specialty"] ?? "Not specified";
              final phone = data["phone"] ?? "-";
              final bio = data["bio"] ??
                  "No bio added yet. You can update this later.";

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // 👨‍⚕️ PROFILE AVATAR
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.medical_services_outlined,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 30),

                    _infoCard("Professional Information", [
                      _infoRow("Specialty", specialty),
                      _infoRow("Phone", phone),
                    ]),

                    const SizedBox(height: 20),

                    _infoCard("About", [
                      Text(
                        bio,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ]),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          "Log Out",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ------------------
  // UI HELPERS
  // ------------------
  Widget _infoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
