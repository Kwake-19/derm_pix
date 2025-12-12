import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



import 'upload_screen.dart';
import 'patient_profile_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  PatientHomeScreenState createState() => PatientHomeScreenState();
}

class PatientHomeScreenState extends State<PatientHomeScreen> {
  final int _currentIndex = 0;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  final List<Widget> _screens = [
    const SizedBox(), // placeholder for Home tab
    UploadScreen(),
    PatientProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // --------------------------
      // Bottom Navigation Bar
      // --------------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) return; // Home is this screen itself
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
      // BODY OF THE SCREEN
      // --------------------------
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('patients')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!;
            final dermId = data['assignedDermatologist'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------
                // HEADER
                // --------------------------
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(25),
                    ),
                  ),
                  child: Column(
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
                        "Your Dermatology Dashboard",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // --------------------------
                // ASSIGNED DERMATOLOGIST
                // --------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: dermId == null
                          ? Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.orange, size: 34),
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
                                Icon(Icons.verified_user,
                                    color: Colors.green, size: 34),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    "Assigned Dermatologist:\n$dermId",
                                    style: TextStyle(
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

                SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
