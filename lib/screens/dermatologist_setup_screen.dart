import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DermatologistSetupScreen extends StatefulWidget {
  const DermatologistSetupScreen({super.key});

  @override
  State<DermatologistSetupScreen> createState() =>
      _DermatologistSetupScreenState();
}

class _DermatologistSetupScreenState extends State<DermatologistSetupScreen> {
  final TextEditingController specialtyController = TextEditingController();
  final TextEditingController clinicController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool loading = false;

  Future<void> saveProfile() async {
    setState(() => loading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseDatabase.instance.ref("users/$uid").update({
        "specialty": specialtyController.text.trim(),
        "clinic": clinicController.text.trim(),
        "phone": phoneController.text.trim(),
        "profileCompleted": true,
      });

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, "/dermatologist-home");
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save profile")),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

       // ✅ DARK APP BAR WITH BACK BUTTON
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6F77),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Setup Profile",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),


      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B6F77), Color(0xFF04242A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                const Text(
                  "Dermatologist Profile Setup",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                _inputField(
                    "Specialty", specialtyController, Icons.medical_services),
                const SizedBox(height: 20),

                _inputField("Clinic / Hospital", clinicController, Icons.local_hospital),
                const SizedBox(height: 20),

                _inputField("Phone Number", phoneController, Icons.phone,
                    keyboard: TextInputType.phone),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: loading ? null : saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0B6F77),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF0B6F77))
                        : const Text(
                            "Save & Continue",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    String hint,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white30),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

