import 'dart:ui';
import 'package:flutter/material.dart';

class AnalyseXray extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final imagePath = args?['xrayImage'];
    final name = args?['name'] ?? 'Not Provided';
    final age = args?['age'] ?? 'N/A';
    final gender = args?['gender'] ?? 'N/A';
    final pain = args?['pain'] ?? 'N/A';
    final location = args?['location'] ?? 'N/A';
    final duration = args?['duration'] ?? 'N/A';
    final visited = args?['visited'] ?? 'N/A';

    return Scaffold(
      backgroundColor: Color(0xFF001F3F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Analysis Report',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),

              // XRAY IMAGE
              if (imagePath != null)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 20)
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(imagePath, height: 200, fit: BoxFit.cover),
                  ),
                ),
              SizedBox(height: 25),

              // Patient Info
              _glowCard(
                icon: Icons.person,
                title: 'Patient Info',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('Name', name),
                    _infoRow('Age', age),
                    _infoRow('Gender', gender),
                    _infoRow('Pain', pain),
                    if (pain == 'Yes') _infoRow('Pain Location', location),
                    _infoRow('Duration', duration),
                    _infoRow('Visited Dentist', visited),
                  ],
                ),
              ),

              // AI FINDINGS
              _glowCard(
                icon: Icons.insights,
                title: 'AI Findings',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _checkItem("Tooth #24 has a cavity"),
                    _checkItem("Mild gum inflammation"),
                    _checkItem("No signs of root damage detected"),
                    SizedBox(height: 20),
                    Text(
                      'Recommendations:',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    _bulletItem("Visit a dentist for a filling"),
                    _bulletItem("Regular cleaning every 6 months"),
                    _bulletItem("Brush twice daily with fluoride toothpaste"),
                  ],
                ),
              ),

              SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/specialistList');
                },
                icon: Icon(Icons.medical_services_outlined),
                label: Text('Find a Dental Specialist'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glowCard({required IconData icon, required String title, required Widget content}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white10, Colors.white.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.cyanAccent),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 14),
          content,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text('$label:', style: TextStyle(color: Colors.white70))),
          Text(value, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _checkItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _bulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(color: Colors.white, fontSize: 16)),
          Expanded(child: Text(text, style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
