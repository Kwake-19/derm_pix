import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  // ------------------
  // CONTROLLERS
  // ------------------
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String selectedRole = "Patient";

  // ------------------
  // ANIMATIONS
  // ------------------
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ------------------
  // SIGN UP LOGIC (FIXED)
  // ------------------
  Future<void> _signUp() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      // 1️⃣ AUTH
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      // 2️⃣ SAVE USER (REALTIME DB)
      await FirebaseDatabase.instance
          .ref("users/$uid")
          .set({
            "name": nameController.text.trim(),
            "email": emailController.text.trim(),
            "role": selectedRole,
            "assignedDermatologist": null,
            "profileCompleted": false,
            "createdAt": DateTime.now().toIso8601String(),
          })
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      setState(() => isLoading = false);

      // 3️⃣ NAVIGATE
      if (selectedRole == "Patient") {
        Navigator.pushReplacementNamed(context, "/patient-setup");
      } else {
        Navigator.pushReplacementNamed(context, "/dermatologist-setup");
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showError(e.message ?? "Signup failed");
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showError("Network or database error. Try again.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ------------------
  // UI
  // ------------------
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
          "Create Account",
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
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    _inputField(
                      hint: "Full Name",
                      controller: nameController,
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 18),

                    _inputField(
                      hint: "Email",
                      controller: emailController,
                      icon: Icons.email,
                      keyboard: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),

                    _inputField(
                      hint: "Password",
                      controller: passwordController,
                      icon: Icons.lock,
                      isPassword: true,
                    ),

                    const SizedBox(height: 28),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Select Role",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        children: [
                          _roleButton("Patient"),
                          _roleButton("Dermatologist"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0B6F77),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Color(0xFF0B6F77),
                              )
                            : const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Already have an account? Log in",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------
  // WIDGETS
  // ------------------
  Widget _inputField({
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
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
        obscureText: isPassword,
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

  Widget _roleButton(String role) {
    final bool active = selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              role,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: active ? const Color(0xFF0B6F77) : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


