import 'package:flutter/material.dart';

// Import screens from the screens folder
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/patient_home_screen.dart';
import '../screens/dermatologist_home_screen.dart';
import '../screens/upload_screen.dart';
import '../screens/patient_detail_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/patient_setup_screen.dart';
import '../screens/dermatologist_setup_screen.dart';


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

      // First screen shown
      initialRoute: '/welcome',

      // App routes
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/patient-home': (_) =>  PatientHomeScreen(),
        '/dermatologist-home': (_) => const DermatologistHomeScreen(),
        '/upload': (_) => const UploadScreen(),
        '/patient-detail': (_) => const PatientDetailScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/patient-setup': (context) => const PatientSetupScreen(),
        '/dermatologist-setup': (context) => const DermatologistSetupScreen(),


      },
    );
  }
}
