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

  final User? _user = FirebaseAuth.instance.currentUser;
  late final Query _userRef;

  @override
  void initState() {
    super.initState();

    if (_user == null) return;

    final uid = _user!.uid;

    // ✅ LISTEN TO DERMATOLOGISTS WHERE THIS PATIENT IS LINKED
    _userRef = FirebaseDatabase.instance
        .ref("dermatologists")
        .orderByChild("patients/$uid")
        .equalTo(true);
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
    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),

      // 🔷 APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6F77),
        elevation: 0,
        title: const Text("Home", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            tooltip: "Scan Dermatologist QR",
            onPressed: () async {
              final linked = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PatientQrScannerScreen(),
                ),
              );

              if (linked == true) {
                setState(() {});
              }
            },
          ),
        ],
      ),

      // 🔷 BOTTOM NAV
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔵 HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0B6F77), Color(0xFF04242A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28)),
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
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "My Specialists",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            // 🔵 DERMATOLOGISTS LIST
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: _userRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      child: _noDermatologistCard(),
                    );
                  }

                  final Map<dynamic, dynamic> data =
                      snapshot.data!.snapshot.value as Map;

                  final List<String> dermUids =
                      data.keys.map((k) => k.toString()).toList();

                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: dermUids.length,
                    itemBuilder: (context, index) {
                      final doctorUid = dermUids[index];

                      return FutureBuilder<Map<String, dynamic>>(
                        future: _loadDermatologist(doctorUid),
                        builder: (context, dermSnapshot) {
                          if (!dermSnapshot.hasData) {
                            return const Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: 8),
                              child: LinearProgressIndicator(
                                  color: Color(0xFF0B6F77)),
                            );
                          }

                          final dermData = dermSnapshot.data!;
                          final dermName =
                              dermData["name"] ?? "Dermatologist";

                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: 12),
                            child: _dermatologistCard(
                              dermatologistUid: doctorUid,
                              dermatologistName: dermName,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
          borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 34),
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
            borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.verified_user,
                  color: Colors.green, size: 34),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dermatologistName,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text("Specialist",
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
