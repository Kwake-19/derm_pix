import 'package:flutter/material.dart';

class DermatologistHomeScreen extends StatefulWidget {
  const DermatologistHomeScreen({super.key});

  @override
  State<DermatologistHomeScreen> createState() =>
      _DermatologistHomeScreenState();
}

class _DermatologistHomeScreenState extends State<DermatologistHomeScreen> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);

    if (index == 1) {
      // 🔜 QR Scanner (later)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("QR scanner coming soon")),
      );
    } else if (index == 2) {
      // ✅ GO TO PROFILE
      Navigator.pushNamed(context, '/dermatologist-profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF04242A),

      // --------------------------
      // APP BAR
      // --------------------------
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6F77),
        elevation: 0,
        title: const Text(
          "Dermatologist Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      // --------------------------
      // BODY
      // --------------------------
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B6F77), Color(0xFF04242A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // 👋 HEADER
                const Text(
                  "Welcome, Dermatologist 👋",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Patients will appear here once they link with you via QR code.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 40),

                // 🩺 EMPTY STATE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.people_outline,
                        size: 70,
                        color: Colors.white70,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No patients yet",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Ask patients to scan your QR code\nor scan theirs to link.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 🔵 SCAN QR BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text(
                      "Scan Patient QR Code",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("QR scanner coming soon"),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0B6F77),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: Text(
                      "DermPix • Secure Dermatology Follow-Up",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // --------------------------
      // BOTTOM NAV BAR
      // --------------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        backgroundColor: const Color(0xFF0B6F77),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: "Scan QR",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
