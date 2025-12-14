import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'patient_profile_screen.dart';
import 'patient_qr_scanner_screen.dart';
import 'patient_dermatologist_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

  final String uid = FirebaseAuth.instance.currentUser!.uid;
  late final DatabaseReference _userRef;

  @override
  void initState() {
    super.initState();
    _userRef = FirebaseDatabase.instance.ref("users/$uid");
  }

  // 🔹 Load dermatologist profile
  Future<Map<String, dynamic>> _loadDermatologist(String dermUid) async {
    final snapshot =
        await FirebaseDatabase.instance.ref("users/$dermUid").get();

    if (!snapshot.exists) {
      throw Exception("Dermatologist not found");
    }

    return Map<String, dynamic>.from(
      snapshot.value as Map<dynamic, dynamic>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),

      // 🔷 APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6F77),
        elevation: 0,
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            tooltip: "Scan Dermatologist QR",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PatientQrScannerScreen(),
                ),
              );
            },
          ),
        ],
      ),

      // 🔷 BOTTOM NAV (NO UPLOAD HERE ❌)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF0B6F77),
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PatientProfileScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),

      // 🔷 BODY
      body: SafeArea(
        child: StreamBuilder<DatabaseEvent>(
          stream: _userRef.onValue,
          builder: (context, snapshot) {
            if (!snapshot.hasData ||
                snapshot.data!.snapshot.value == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final userData = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map,
            );

            final String? dermatologistUid =
                userData["assignedDermatologist"];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔵 HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF0B6F77),
                        Color(0xFF04242A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back 👋",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Your dermatology dashboard",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 🔵 DERMATOLOGIST CARD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: dermatologistUid == null
                      ? _noDermatologistCard()
                      : FutureBuilder<Map<String, dynamic>>(
                          future:
                              _loadDermatologist(dermatologistUid),
                          builder: (context, dermSnapshot) {
                            if (!dermSnapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final dermData = dermSnapshot.data!;
                            final dermName =
                                dermData["name"] ?? "Dermatologist";

                            return _dermatologistCard(
                              dermatologistUid: dermatologistUid,
                              dermatologistName: dermName,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // -----------------------
  // UI HELPERS
  // -----------------------

  Widget _noDermatologistCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 34,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                "No dermatologist assigned.\nScan a QR code to link.",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dermatologistCard({
    required String dermatologistUid,
    required String dermatologistName,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientDermatologistScreen(
              dermatologistUid: dermatologistUid,
              dermatologistName: dermatologistName,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(
                Icons.verified_user,
                color: Colors.green,
                size: 34,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Dermatologist:\n$dermatologistName\n\nTap to view uploads",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
