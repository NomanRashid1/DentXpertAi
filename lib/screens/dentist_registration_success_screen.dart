import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DentistRegistrationSuccessScreen extends StatefulWidget {
  final String name;
  final String specialization;

  const DentistRegistrationSuccessScreen({
    Key? key,
    required this.name,
    required this.specialization,
  }) : super(key: key);

  @override
  State<DentistRegistrationSuccessScreen> createState() =>
      _DentistRegistrationSuccessScreenState();
}

class _DentistRegistrationSuccessScreenState
    extends State<DentistRegistrationSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Log registration
    FirebaseFirestore.instance.collection('dentist_logs').add({
      'name': widget.name,
      'specialization': widget.specialization,
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glowing icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyanAccent.withOpacity(0.3),
                          Colors.white12
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: Colors.cyanAccent,
                      size: 80,
                    ),
                  ),

                  const SizedBox(height: 30),
                  Text(
                    'Welcome, Dr. ${widget.name}!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Specialization: ${widget.specialization}',
                    style:
                    const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your profile has been successfully registered on DentXpertAI. Patients can now find and book you directly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),

                  const SizedBox(height: 40),

                  // View Listing Button
                  ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/specialistList'),
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Your Listing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 8,
                      shadowColor: Colors.cyanAccent.withOpacity(0.4),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/home'),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
