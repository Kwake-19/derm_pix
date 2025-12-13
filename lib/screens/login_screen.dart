import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    _fade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slide = Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  Future<void> loginUser() async {
    setState(() => loading = true);

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = cred.user!.uid;

      final snapshot =
          await FirebaseDatabase.instance.ref("users/$uid").get();

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      if (!mounted) return;

      if (data["role"] == "Patient") {
        Navigator.pushReplacementNamed(
          context,
          data["profileCompleted"] ? "/patient-home" : "/patient-setup",
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          data["profileCompleted"]
              ? "/dermatologist-home"
              : "/dermatologist-setup",
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Login failed")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,

      // ✅ TRANSPARENT APP BAR WITH VISIBLE BACK BUTTON
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),


      body: _gradientBody(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome Back",
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            _input("Email", emailController, Icons.email),
            const SizedBox(height: 20),
            _input("Password", passwordController, Icons.lock, true),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading ? null : loginUser,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Log in"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientBody(Widget child) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B6F77), Color(0xFF04242A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(bottom: false, child: Padding(
          padding: const EdgeInsets.all(26),
          child: FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: child)),
        )),
      );

  Widget _input(String hint, TextEditingController c, IconData i, [bool p = false]) {
    return TextField(
      controller: c,
      obscureText: p,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(i, color: Colors.white),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
      ),
    );
  }
}

