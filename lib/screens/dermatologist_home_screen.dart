import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'dermatologist_patient_screen.dart';

class DermatologistHomeScreen extends StatefulWidget {
  const DermatologistHomeScreen({super.key});

  @override
  State<DermatologistHomeScreen> createState() =>
      _DermatologistHomeScreenState();
}

class _DermatologistHomeScreenState extends State<DermatologistHomeScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  late final DatabaseReference patientsRef;

  @override
  void initState() {
    super.initState();

    if (_user == null) return;

    patientsRef = FirebaseDatabase.instance
        .ref("dermatologists/${_user!.uid}/patients");
  }

  // 🔹 Load patient public name
  Future<String> _loadPatientName(String patientUid) async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref("users/$patientUid/name")
          .get();

      return snapshot.exists
          ? snapshot.value.toString()
          : "Unnamed Patient";
    } catch (_) {
      return "Unknown Patient";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F7),

      // 🌊 APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6F77),
        elevation: 0,
        title: const Text("My Patients"),
        centerTitle: true,
      ),

      body: Column(
        children: [
          _header(),

          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: patientsRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return _emptyState();
                }

                final Map<dynamic, dynamic> patients =
                    snapshot.data!.snapshot.value as Map;

                final patientUids =
                    patients.keys.map((e) => e.toString()).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: patientUids.length,
                  itemBuilder: (context, index) {
                    return _patientCard(patientUids[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // 🔻 BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0B6F77),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: "Patients",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: "My QR",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/dermatologist-qr');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/dermatologist-profile');
          }
        },
      ),
    );
  }

  // 🌈 HEADER
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome back 👋",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Here are your connected patients",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // 🌫️ EMPTY STATE
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.qr_code_scanner,
                size: 72, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              "No patients yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Share your QR code with patients\nto get started.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // 👤 PATIENT CARD
  Widget _patientCard(String patientUid) {
    return FutureBuilder<String>(
      future: _loadPatientName(patientUid),
      builder: (context, snapshot) {
        final name = snapshot.data ?? "Loading...";
        final initials =
            name.isNotEmpty ? name[0].toUpperCase() : "?";

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF0B6F77),
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: const Text(
              "Active patient",
              style: TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(Icons.chevron_right),

            // ✅ FIXED NAVIGATION
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DermatologistPatientScreen(
                    patientUid: patientUid,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
