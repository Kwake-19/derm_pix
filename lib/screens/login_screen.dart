import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String userType = "patient"; // patient or dermatologist

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text("Patient"),
                    value: "patient",
                    groupValue: userType,
                    onChanged: (value) {
                      setState(() {
                        userType = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text("Dermatologist"),
                    value: "dermatologist",
                    groupValue: userType,
                    onChanged: (value) {
                      setState(() {
                        userType = value!;
                      });
                    },
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (userType == "patient") {
                  Navigator.pushNamed(context, '/patient-home');
                } else {
                  Navigator.pushNamed(context, '/dermatologist-home');
                }
              },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
