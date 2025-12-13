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

  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref();

  Future<void> _handleScan(String rawValue) async {
    if (_isProcessing) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isProcessing = true);
    _scannerController.stop();

    try {
      final decoded = jsonDecode(rawValue);

      if (decoded is! Map ||
          decoded["type"] != "derm_pix_connect" ||
          decoded["doctorUid"] == null) {
        throw Exception("Invalid QR");
      }

      await _dbRef.child("connections/${user.uid}").set({
        "doctorUid": decoded["doctorUid"],
        "connectedAt": ServerValue.timestamp,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully linked to dermatologist"),
        ),
      );

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid or unsupported QR code"),
        ),
      );

      _scannerController.start();
      setState(() => _isProcessing = false);
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
