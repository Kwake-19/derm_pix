import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'upload_screen.dart';
import 'patient_profile_screen.dart';
import 'package:derm_pix/screens/patient_qr_scanner_screen.dart';


class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final int _currentIndex = 0;

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  late final DatabaseReference userRef;

  final List<Widget> _screens = const [
    SizedBox(), // Home placeholder
    UploadScreen(),
    PatientProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    userRef = FirebaseDatabase.instance.ref("users/$uid");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
 // ✅ DARK APP BAR WITH BACK BUTTON
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6F77),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
         actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: "Scan dermatologist QR",
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
      // --------------------------
      // Bottom Navigation Bar
      // --------------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) return;

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => _screens[index]),
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file_outlined),
            label: "Upload",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),

      // --------------------------
      // BODY
      // --------------------------
      body: SafeArea(
        child: StreamBuilder<DatabaseEvent>(
          stream: userRef.onValue,
          builder: (context, snapshot) {
            if (!snapshot.hasData ||
                snapshot.data!.snapshot.value == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map,
            );

            final dermId = data["assignedDermatologist"];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------
                // HEADER
                // --------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color.fromARGB(255, 127, 43, 228), Color.fromARGB(255, 83, 25, 176)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(25),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Your Dashboard",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --------------------------
                // ASSIGNED DERMATOLOGIST
                // --------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: dermId == null
                          ? Row(
                              children: const [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange,
                                  size: 34,
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    "No dermatologist assigned.\nUse the QR scanner to subscribe.",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                const Icon(
                                  Icons.verified_user,
                                  color: Colors.green,
                                  size: 34,
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    "Assigned Dermatologist:\n$dermId",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
