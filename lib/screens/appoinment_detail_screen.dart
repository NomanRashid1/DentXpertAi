import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final String userEmail;

  const AppointmentDetailScreen({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Appointments"),
        backgroundColor: const Color(0xFF004080),
      ),
      backgroundColor: const Color(0xFF001F3F),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('patientEmail', isEqualTo: userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Appointments Found", style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              final appointment = doc.data() as Map<String, dynamic>;
              final status = appointment['status'] ?? 'pending';
              final assignedTime = appointment['assignedTime'] ?? 'Not assigned';
              final videoLink = appointment['videoLink'];

              return Card(
                color: Colors.white10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("🧑‍⚕️ Doctor: ${appointment['doctorName'] ?? 'N/A'}", style: const TextStyle(color: Colors.white)),
                      Text("📋 Issue: ${appointment['issue'] ?? 'N/A'}", style: const TextStyle(color: Colors.white70)),
                      Text("📆 Status: $status", style: const TextStyle(color: Colors.white70)),
                      Text("🕒 Time: $assignedTime", style: const TextStyle(color: Colors.white70)),
                      if (status == 'confirmed' && videoLink != null) ...[
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(videoLink);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("❌ Could not launch video link"), backgroundColor: Colors.red),
                              );
                            }
                          },
                          icon: const Icon(Icons.video_call),
                          label: const Text("Join Meeting"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
                        )
                      ]
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
