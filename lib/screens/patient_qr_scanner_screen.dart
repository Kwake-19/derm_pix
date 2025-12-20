import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PatientQrScannerScreen extends StatefulWidget {
  const PatientQrScannerScreen({super.key});

  @override
  State<PatientQrScannerScreen> createState() =>
      _PatientQrScannerScreenState();
}

class _PatientQrScannerScreenState extends State<PatientQrScannerScreen> {
  bool _isProcessing = false;

  final MobileScannerController _scannerController =
      MobileScannerController();

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> _handleScan(String rawValue) async {
    if (_isProcessing) return;

    // Quick filter for non-JSON frames
    if (!rawValue.trim().startsWith('{')) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final decoded = jsonDecode(rawValue);

      if (decoded is! Map<String, dynamic>) return;
      if (decoded["type"] != "derm_pix_connect") return;
      if (decoded["doctorUid"] == null) return;

      setState(() => _isProcessing = true);
      _scannerController.stop();

      final String doctorUid = decoded["doctorUid"];

      // ✅ SINGLE SOURCE OF TRUTH
      await _db
          .child("dermatologists")
          .child(doctorUid)
          .child("patients")
          .child(user.uid)
          .set(true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully linked to dermatologist"),
        ),
      );

      // ✅ RETURN SUCCESS TO HOME SCREEN
      Navigator.pop(context, true);
    } catch (e) {
      // Restart scanner on failure
      if (mounted) {
        _scannerController.start();
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04242A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6F77),
        title: const Text("Scan Dermatologist QR"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Align the QR code inside the frame",
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                final barcode = capture.barcodes.first;
                final rawValue = barcode.rawValue;
                if (rawValue != null) {
                  _handleScan(rawValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
