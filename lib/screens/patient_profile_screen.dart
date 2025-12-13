import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../main.dart'; // contains cameras
import 'camera_capture_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  File? _localProfileImage;

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
  // OPEN REAL-TIME CAMERA
  // ------------------
  Future<void> _openCamera() async {
    final File? imageFile = await Navigator.push<File?>(
      context,
      MaterialPageRoute(
        builder: (_) => CameraCaptureScreen(
          camera: cameras.first,
        ),
      ),
    );

    if (imageFile != null && mounted) {
      setState(() {
        _localProfileImage = imageFile;
      });
    }
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
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF04242A),

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
          bottom: false,
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
              final name = data["name"] ?? "Patient";
              final email = data["email"] ?? "-";
              final age = data["age"] ?? "-";
              final phone = data["phone"] ?? "-";
              final condition = data["condition"] ?? "-";
              final dermatologist =
                  data["assignedDermatologist"] ?? "Not assigned";

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // 👤 PROFILE IMAGE
                    GestureDetector(
                      onTap: _openCamera,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            backgroundImage: _localProfileImage != null
                                ? FileImage(_localProfileImage!)
                                : null,
                            child: _localProfileImage == null
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Color(0xFF0B6F77),
                            ),
                          ),
                        ],
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

                    _infoCard("Patient Information", [
                      _infoRow("Age", age),
                      _infoRow("Phone", phone),
                      _infoRow("Condition", condition),
                      _infoRow("Dermatologist", dermatologist),
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

