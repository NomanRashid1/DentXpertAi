import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'user_appointment_screen.dart'; // ✅ Your appointment screen

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF001F3F), Color(0xFF003566)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'DentXpertAI',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 12, color: Colors.cyanAccent)],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _homeCard(
                    icon: Icons.local_hospital_outlined,
                    title: 'Find a Dentist',
                    subtitle: 'Search trusted dental specialists',
                    onTap: () => Navigator.pushNamed(context, '/specialistList'),
                  ),
                  const SizedBox(height: 16),
                  _homeCard(
                    icon: Icons.calendar_today,
                    title: 'My Appointments',
                    subtitle: 'View your scheduled dental visits',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserAppointmentsScreen()),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ✅ Show next appointment card


                  const SizedBox(height: 24),
                  const Text(
                    'Tips for Healthy Teeth',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _tipsList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.3), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.cyanAccent, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white38),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _NextAppointmentCard(String userEmail) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('patientEmail', isEqualTo: userEmail)
          .where('status', isEqualTo: 'confirmed')
          .orderBy('date')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Text(
            'No upcoming confirmed appointments.',
            style: TextStyle(color: Colors.white70),
          );
        }

        final data = docs.first.data() as Map<String, dynamic>;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Next Appointment",
                  style: TextStyle(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Doctor: Dr. ${data['doctorName'] ?? ''}",
                  style: const TextStyle(color: Colors.white)),
              Text("Date: ${data['date'] ?? ''}",
                  style: const TextStyle(color: Colors.white)),
              if (data['assignedTime'] != null && data['assignedTime'].toString().isNotEmpty)
                Text("Time: ${data['assignedTime']}", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 10),
              if (data['videoLink'] != null && data['videoLink'].toString().isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(data['videoLink']);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Unable to open video call link")),
                      );
                    }
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text("Join Video Call"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _tipsList() {
    final tips = [
      "Brush twice daily",
      "Floss regularly",
      "Avoid sugary snacks",
      "Visit the dentist every 6 months",
      "Replace toothbrush often"
    ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: tips.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.cyanAccent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tips[index],
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
