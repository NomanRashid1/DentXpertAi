import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'models/patient_model.dart';
import 'services/config_service.dart';
import 'widgets/glass_card.dart';

class ResultsScreen extends StatelessWidget {
  final Patient patient;
  final Uint8List? pdfBytes;
  final bool emailSent;

  const ResultsScreen({
    super.key,
    required this.patient,
    this.pdfBytes,
    required this.emailSent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConfig.accentColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Analysis Results',
          style: TextStyle(color: AppConfig.accentColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            GlassCard(
              title: "STATUS",
              children: [
                Row(
                  children: [
                    Icon(
                      emailSent ? Icons.check_circle : Icons.warning,
                      color: emailSent ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        emailSent
                            ? 'Report sent successfully to ${patient.email}'
                            : 'Report generated successfully',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: emailSent ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Patient Info Card
            GlassCard(
              title: "PATIENT INFORMATION",
              children: [
                _infoRow("Name", patient.name ?? 'Not Provided'),
                _infoRow("Age", patient.age),
                _infoRow("Gender", patient.gender),
                _infoRow("Pain", patient.pain),
                if (patient.pain == 'Yes')
                  _infoRow(
                    "Pain Location",
                    patient.painLocation ?? 'Not specified',
                  ),
                _infoRow("Pain Duration", patient.duration),
                _infoRow("Visited Dentist", patient.visitedDentist),
                _infoRow("Email", patient.email),
              ],
            ),

            // Actions Card
            GlassCard(
              title: "ACTIONS",
              children: [
                if (pdfBytes != null)
                  ElevatedButton.icon(
                    onPressed: () => _savePdf(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.accentColor,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.download),
                    label: const Text('Download PDF Report'),
                  ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Home'),
                ),
              ],
            ),

            // Note
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Note: This is an AI-generated analysis. '
                'Please consult with a dental professional for proper diagnosis.',
                style: TextStyle(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _savePdf(BuildContext context) async {
    if (pdfBytes == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'Dental_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(pdfBytes!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ PDF saved to: ${file.path}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to save PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
