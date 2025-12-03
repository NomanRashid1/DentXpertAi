import 'dart:ui';
import 'package:flutter/material.dart';

class DoctorChoiceScreen extends StatelessWidget {
  const DoctorChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF002E46), Color(0xFF003E5C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 28,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xAA0D1B2A), // Better glass tone
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: const Color(0x33FFFFFF), // Subtle white border
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FFF7),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF00FFF7,
                              ).withValues(alpha: 0.9),
                              blurRadius: 50,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 36),
                      const Text(
                        "Welcome Dentist!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Register a new profile or login\nto manage your appointments\nand availability.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 36),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/dentistRegistration');
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text("Register as Doctor"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FFF7),
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/doctorLogin');
                        },
                        icon: const Icon(Icons.lock_outline),
                        label: const Text("Login as Doctor"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFF00FFF7),
                            width: 1.5,
                          ),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
