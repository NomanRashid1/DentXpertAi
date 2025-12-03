import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> appointmentData;
  final String appointmentId;

  const PaymentScreen({
    super.key,
    required this.appointmentData,
    required this.appointmentId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  File? _proofImage;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _proofImage = File(picked.path);
      });
    }
  }

  Future<void> _processPayment() async {
    if (_proofImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload a payment proof image")),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Convert image to Base64
      final bytes = await _proofImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .update({
            'paymentStatus': 'uploaded',
            'status': 'pending',
            'transactionProofBase64': base64Image,
          });

      setState(() => _isProcessing = false);

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Payment Submitted"),
              content: const Text(
                "Your proof has been saved. You'll be notified once the doctor confirms.",
              ),
              actions: [
                TextButton(
                  onPressed:
                      () => Navigator.popUntil(
                        context,
                        ModalRoute.withName('/userHome'),
                      ),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointmentData;
    final charges = appointment['charges'];

    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Confirm Payment',
          style: TextStyle(
            color: Colors.cyanAccent,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCard(appointment, charges),
            const SizedBox(height: 20),
            _buildUploadProofSection(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
                shadowColor: Colors.cyanAccent.withValues(alpha: 0.4),
              ),
              child:
                  _isProcessing
                      ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Uploading...",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                      : const Text(
                        'Submit Payment Proof',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> appointment, String charges) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF013A63), Color(0xFF026384)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appointment Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Doctor:',
              'Dr. ${appointment['doctor']['name'] ?? 'N/A'}',
            ),
            _buildSummaryRow('Date:', appointment['date'] ?? 'N/A'),
            _buildSummaryRow('Time:', appointment['assignedTime'] ?? 'N/A'),
            _buildSummaryRow('Mode:', appointment['consultationMode'] ?? 'N/A'),
            const Divider(color: Colors.cyanAccent, thickness: 1),
            _buildSummaryRow('Total Charges:', 'PKR $charges', bold: true),
            if (appointment['emergencySelected'] == true)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: const [
                    Icon(Icons.emergency, color: Colors.redAccent, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Emergency Appointment',
                        style: TextStyle(fontSize: 14, color: Colors.redAccent),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: bold ? Color(0xFFFFD700) : Colors.white,
                fontSize: 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProofSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Proof of Payment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.cyanAccent,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.cyanAccent.withValues(alpha: 0.4),
              ),
            ),
            child:
                _proofImage == null
                    ? const Center(
                      child: Text(
                        "Tap to upload image",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_proofImage!, fit: BoxFit.cover),
                    ),
          ),
        ),
      ],
    );
  }
}
