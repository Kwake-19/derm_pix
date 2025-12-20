import 'package:flutter/material.dart';

// Import screens
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/patient_home_screen.dart';
import '../screens/dermatologist_home_screen.dart';
import '../screens/patient_detail_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/patient_setup_screen.dart';
import '../screens/dermatologist_setup_screen.dart';
import '../screens/dermatologist_profile_screen.dart';
import '../screens/dermatologist_qr_screen.dart';

class DermPixApp extends StatelessWidget {
  const DermPixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DermPix',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),

      // Initial screen
      initialRoute: '/welcome',

      // App routes
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const LoginScreen(),

        // Home screens
        '/patient-home': (_) => const PatientHomeScreen(),
        '/dermatologist-home': (_) => const DermatologistHomeScreen(),

        // Setup & profile
        '/signup': (_) => const SignUpScreen(),
        '/patient-setup': (_) => const PatientSetupScreen(),
        '/dermatologist-setup': (_) =>
            const DermatologistSetupScreen(),
        '/dermatologist-profile': (_) =>
            const DermatologistProfileScreen(),
        '/dermatologist-qr': (_) =>
            const DermatologistQrScreen(),

        // Patient detail (doctor-side)
        '/patient-detail': (_) => const PatientDetailScreen(),
      },
    );
  }
}
