import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DermatologistHomeScreen extends StatefulWidget {
  const DermatologistHomeScreen({super.key});

  @override
  State<DermatologistHomeScreen> createState() =>
      _DermatologistHomeScreenState();
}

class _DermatologistHomeScreenState extends State<DermatologistHomeScreen> {
  final String dermUid = FirebaseAuth.instance.currentUser!.uid;

  late final DatabaseReference patientsRef;

  @override
  void initState() {
    super.initState();
    patientsRef =
        FirebaseDatabase.instance.ref("dermatologists/$dermUid/patients");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04242A),

      // 🔷 APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6F77),
        elevation: 0,
        title: const Text(
          "Dermatologist Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      // 🔷 BODY
      body: StreamBuilder<DatabaseEvent>(
        stream: patientsRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {
            return _emptyState();
          }

          final patients = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: patients.keys.map((patientUid) {
              return _patientCard(patientUid);
            }).toList(),
          );
        },
      ),

      // 🔷 BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0B6F77),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
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

  // ------------------
  // EMPTY STATE
  // ------------------
  Widget _emptyState() {
    return const Center(
      child: Text(
        "No patients yet.\nAsk patients to scan your QR code.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }

  // ------------------
  // PATIENT CARD
  // ------------------
  Widget _patientCard(String patientUid) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text("Patient ID"),
        subtitle: Text(patientUid),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // ✅ THIS WILL GO TO A DERMATOLOGIST-SIDE SCREEN
          Navigator.pushNamed(
            context,
            '/dermatologist-patient',
            arguments: patientUid,
          );
        },
      ),
    );
  }
}

