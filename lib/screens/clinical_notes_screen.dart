import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class ClinicalNotesScreen extends StatefulWidget {
  final String imageUrl;
  final int uploadedAt;
  final String patientName;
  final String patientUid;
  final String dermatologistUid;
  final String uploadId;
  final String status;

  const ClinicalNotesScreen({
    super.key,
    required this.imageUrl,
    required this.uploadedAt,
    required this.patientName,
    required this.patientUid,
    required this.dermatologistUid,
    required this.uploadId,
    required this.status,
  });

  @override
  State<ClinicalNotesScreen> createState() => _ClinicalNotesScreenState();
}

class _ClinicalNotesScreenState extends State<ClinicalNotesScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _saving = false;

  late final DatabaseReference _uploadRef;

  @override
  void initState() {
    super.initState();
    _uploadRef = FirebaseDatabase.instance.ref(
      'uploads/${widget.patientUid}/${widget.dermatologistUid}/${widget.uploadId}',
    );
    _loadExistingNote();
  }

  Future<void> _loadExistingNote() async {
    final snap = await _uploadRef.child('note/text').get();
    if (snap.exists && snap.value is String) {
      _notesController.text = snap.value as String;
    }
  }

  Future<void> _saveNote() async {
    setState(() => _saving = true);

    await _uploadRef.update({
      'status': 'reviewed',
      'note': {
        'text': _notesController.text.trim(),
        'reviewedAt': ServerValue.timestamp,
      },
    });

    if (!mounted) return;

    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Clinical note saved")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMMd()
        .add_jm()
        .format(DateTime.fromMillisecondsSinceEpoch(widget.uploadedAt));

    final isReviewed = widget.status == 'reviewed';

    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ IMPORTANT
      backgroundColor: const Color(0xFFF2F6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6F77),
        title: const Text("Clinical Notes"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // ✅ KEY FIX
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.top,
            ),
            child: Column(
              children: [
                // ───────── IMAGE CONTEXT ─────────
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Image.network(
                          widget.imageUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 14, color: Color(0xFF0B6F77)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                date,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _statusChip(isReviewed),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ───────── NOTES ─────────
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Clinical Notes",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _notesController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText:
                              "Observations, diagnosis, treatment response, next steps…",
                          filled: true,
                          fillColor: const Color(0xFFF7F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _saveNote,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B6F77),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _saving
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text("Save Notes"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(bool reviewed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: reviewed ? const Color(0xFFE6F4EA) : const Color(0xFFFFFBEB),
        border: Border.all(
          color: reviewed ? Colors.green : Colors.orange,
        ),
      ),
      child: Text(
        reviewed ? "Reviewed" : "Pending",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: reviewed ? Colors.green : Colors.orange,
        ),
      ),
    );
  }
}


