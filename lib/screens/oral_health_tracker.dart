import 'package:flutter/material.dart';

class OralHealthTrackerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Oral Health Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF00E0FF),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCard(
                icon: Icons.checklist,
                title: 'Daily Hygiene Log',
                subtitle: 'Track brushing, flossing, mouthwash',
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
                onTap: () {},
              ),
              _buildCard(
                icon: Icons.mood,
                title: 'Symptoms Tracker',
                subtitle: 'Log any pain or discomfort',
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
                onTap: () {},
              ),
              _buildCard(
                icon: Icons.history,
                title: 'Treatment History',
                subtitle: 'See your past treatments',
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
                onTap: () {},
              ),
              _buildCard(
                icon: Icons.alarm,
                title: 'Medication Reminders',
                subtitle: 'Don’t miss a dose!',
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
                onTap: () {},
              ),
              _buildCard(
                icon: Icons.stacked_line_chart,
                title: 'Oral Health Score',
                subtitle: 'Track your overall score',
                trailing: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                  child: const Text('8.7', style: TextStyle(color: Colors.white)),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF003D5B), Color(0xFF002B5B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.cyanAccent.withOpacity(0.2),
              child: Icon(icon, size: 28, color: Colors.cyanAccent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
