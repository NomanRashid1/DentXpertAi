import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // ← FIXED: no overflow on small screens
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // IMAGE
                  Image.asset('assets/rebot_rebot.png', height: 350),

                  const SizedBox(height: 20),

                  // MAIN TITLE
                  const Text(
                    'DentXpertAI',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                      color: Colors.cyanAccent,
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: Colors.cyanAccent,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // SUBTITLE
                  const Text(
                    'Smarter Dental Diagnosis\n& AI-Powered Specialist Booking',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),

                  const SizedBox(height: 40),

                  // BUTTON 1
                  _primaryButton(
                    context,
                    icon: Icons.person_outline,
                    label: 'Explore as a Patient',
                    onTap:
                        () => Navigator.pushNamed(context, '/userEmailInput'),
                  ),

                  const SizedBox(height: 20),

                  // BUTTON 2
                  _primaryButton(
                    context,
                    icon: Icons.add,
                    label: 'Register as a Dental Specialist',
                    onTap: () => Navigator.pushNamed(context, '/doctorChoice'),
                  ),

                  const SizedBox(height: 40),

                  // FOOTER TEXT
                  const Text(
                    '🦷 Bringing AI to your dental care experience',
                    style: TextStyle(fontSize: 12, color: Colors.white38),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // CUSTOM BUTTON WIDGET
  Widget _primaryButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyanAccent.withValues(alpha: 0.15),
          foregroundColor: Colors.white,
          shadowColor: Colors.cyanAccent,
          elevation: 4,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.cyanAccent, width: 1),
          ),
        ),
        icon: Icon(icon, color: Colors.cyanAccent),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: onTap,
      ),
    );
  }
}
