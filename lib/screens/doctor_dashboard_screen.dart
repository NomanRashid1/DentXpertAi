import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'edit_doctor_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorDashboardScreen extends StatefulWidget {
  final String doctorEmail;

  const DoctorDashboardScreen({super.key, required this.doctorEmail});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  Future<DocumentSnapshot?>? _doctorDataFuture;

  @override
  void initState() {
    super.initState();
    _doctorDataFuture = _fetchDoctorData();
  }

  Future<DocumentSnapshot?> _fetchDoctorData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('dentists')
        .where('email', isEqualTo: widget.doctorEmail)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    }
    return null;
  }

  void _editProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditDoctorProfileScreen(
          doctorEmail: widget.doctorEmail,
        ),
      ),
    );

    setState(() {
      _doctorDataFuture = _fetchDoctorData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF001F3F), Color(0xFF004080)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: FutureBuilder<DocumentSnapshot?>(
              future: _doctorDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.cyanAccent),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: Text(
                      'Doctor data not found.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;

                final experienceValue = data['experience'];
                String experienceString;
                if (experienceValue is int) {
                  experienceString = experienceValue.toString();
                } else if (experienceValue is String) {
                  experienceString = experienceValue;
                } else {
                  experienceString = 'N/A';
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.cyanAccent,
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Dr. ${data['name'] ?? ''}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              data['specialization'] ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildInfoTile(
                        'Clinic Address',
                        data['clinicAddress'] ?? '',
                      ),
                      _buildInfoTile('Charges (PKR)', data['charges'] ?? ''),
                      _buildInfoTile('Email', data['email'] ?? ''),
                      _buildInfoTile('Phone', data['phone'] ?? ''),
                      _buildInfoTile('Experience', experienceString),
                      _buildInfoTile('Bio', data['bio'] ?? ''),
                      const SizedBox(height: 30),

                      // ✅ FIXED: Using pushNamed with route instead of direct class
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/doctorAppointments',
                            arguments: {'doctorEmail': widget.doctorEmail},
                          );
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text("My Appointments"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: _editProfile,
                        icon: const Icon(Icons.edit, color: Colors.cyanAccent),
                        label: const Text("Edit Profile"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.cyanAccent,
                          side: const BorderSide(color: Colors.cyanAccent),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}