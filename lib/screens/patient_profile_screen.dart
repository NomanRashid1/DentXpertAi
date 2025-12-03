import 'package:flutter/material.dart';

class PatientProfileScreen extends StatelessWidget {
  final Map<String, dynamic> appointmentData;

  const PatientProfileScreen({super.key, required this.appointmentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      appBar: AppBar(
        title: const Text("Patient Profile"),
        backgroundColor: const Color(0xFF004080),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyanAccent, width: 1.5),
            color: Colors.white10,
          ),
          child: ListView(
            children: [
              _buildRow('Patient Name', appointmentData['patientName']),
              _buildRow('Age', appointmentData['age']?.toString() ?? 'N/A'),
              _buildRow('Gender', appointmentData['gender'] ?? 'N/A'),
              _buildRow('Issue', appointmentData['issue']),
              _buildRow(
                'Consultation Mode',
                appointmentData['consultationMode'],
              ),
              _buildRow('Selected Date', appointmentData['selectedDate']),
              _buildRow('Selected Time', appointmentData['selectedTimeSlot']),
              _buildRow(
                'Emergency',
                appointmentData['emergencySelected'] == true ? 'Yes' : 'No',
              ),
              _buildRow('Status', appointmentData['status']),
              _buildRow('Doctor', appointmentData['doctor']?['name'] ?? 'N/A'),
              if (appointmentData['xrayUrl'] != null &&
                  appointmentData['xrayUrl'].toString().isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (_) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(appointmentData['xrayUrl']),
                            ),
                          ),
                    );
                  },
                  icon: const Icon(Icons.image, color: Colors.cyanAccent),
                  label: const Text(
                    "View X-ray",
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
