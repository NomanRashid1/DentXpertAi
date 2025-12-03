import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyDentalScreen extends StatelessWidget {
  const EmergencyDentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text(
          'Dental Emergency',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Critical Emergency Section
            _buildCriticalEmergencyCard(context),
            const SizedBox(height: 20),

            // Symptom Checker
            _buildSymptomCheckerCard(context),
            const SizedBox(height: 20),

            // Emergency Contacts
            _buildEmergencyContactsCard(),
            const SizedBox(height: 20),

            // First Aid Guides
            _buildFirstAidGuidesCard(context),
            const SizedBox(height: 20),

            // Clinic Locator
            _buildClinicLocatorCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalEmergencyCard(BuildContext context) {
    return Card(
      color: Colors.red[900]!.withValues(alpha: 0.2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red[700]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'CRITICAL EMERGENCY',
                  style: TextStyle(
                    color: Colors.red[300],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'If you experience any of these, seek help immediately:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• Difficulty breathing/swallowing',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    '• Uncontrolled bleeding',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    '• Severe facial trauma',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    '• Swelling affecting vision',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchEmergencyCall('911'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.emergency),
                label: const Text('CALL EMERGENCY SERVICES'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomCheckerCard(BuildContext context) {
    return Card(
      color: const Color(0xFF1C2541),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Symptom Checker',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select your symptoms to get guidance:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSymptomChip('Severe pain'),
                _buildSymptomChip('Swollen face'),
                _buildSymptomChip('Bleeding gums'),
                _buildSymptomChip('Knocked-out tooth'),
                _buildSymptomChip('Broken tooth'),
                _buildSymptomChip('Lost filling'),
                _buildSymptomChip('Abscess'),
                _buildSymptomChip('Jaw pain'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showTriageResult(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B4D8),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('ANALYZE SYMPTOMS'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomChip(String text) {
    return ChoiceChip(
      label: Text(text, style: const TextStyle(color: Colors.white)),
      selected: false,
      onSelected: (bool selected) {},
      selectedColor: Colors.blue[800],
      backgroundColor: const Color(0xFF2C3654),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildEmergencyContactsCard() {
    return Card(
      color: const Color(0xFF1C2541),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Contacts',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            _buildContactTile(
              icon: Icons.local_hospital,
              title: 'Nearest Dental Hospital',
              subtitle: 'Open 24/7 - 5.2 miles away',
              onTap: () => _launchEmergencyCall('18005551234'),
            ),
            const Divider(color: Colors.white24, height: 24),
            _buildContactTile(
              icon: Icons.medical_services,
              title: 'Your Dentist: Dr. Ayesha Khan',
              subtitle: 'After-hours: (555) 123-4567',
              onTap: () => _launchEmergencyCall('5551234567'),
            ),
            const Divider(color: Colors.white24, height: 24),
            _buildContactTile(
              icon: Icons.support_agent,
              title: 'Dental Emergency Hotline',
              subtitle: '24/7 free consultation',
              onTap: () => _launchEmergencyCall('18005559876'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[800]!.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue[200]),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.call, color: Colors.green),
        onPressed: onTap,
      ),
      onTap: onTap,
    );
  }

  Widget _buildFirstAidGuidesCard(BuildContext context) {
    return Card(
      color: const Color(0xFF1C2541),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'First Aid Guides',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            _buildFirstAidItem(
              context,
              title: 'Knocked-out Tooth',
              icon: Icons.health_and_safety,
            ),
            _buildFirstAidItem(
              context,
              title: 'Broken Tooth',
              icon: Icons.build,
            ),
            _buildFirstAidItem(
              context,
              title: 'Severe Toothache',
              icon: Icons.sick,
            ),
            _buildFirstAidItem(
              context,
              title: 'Bleeding Gums',
              icon: Icons.bloodtype,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstAidItem(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple[800]!.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.purple[200]),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: () => _showFirstAidGuide(context, title),
      ),
    );
  }

  Widget _buildClinicLocatorCard(BuildContext context) {
    return Card(
      color: const Color(0xFF1C2541),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Clinics Nearby',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.grey[900],
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 40, color: Colors.white54),
                      SizedBox(height: 8),
                      Text(
                        'Map View Would Display Here',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.directions, size: 20),
                    label: const Text('GET DIRECTIONS'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.schedule, size: 20),
                    label: const Text('BOOK URGENT APPOINTMENT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmergencyCall(String number) async {
    final Uri url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showTriageResult(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1C2541),
            title: const Text(
              'Symptom Analysis',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[900]!.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Urgent Care Needed',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Based on your symptoms, you should:',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• See a dentist within 6 hours',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        '• Apply cold compress to reduce swelling',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        '• Avoid hot foods/drinks',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        '• Take OTC pain reliever if needed',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () => _launchEmergencyCall('5551234567'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                ),
                child: const Text('Call Dentist Now'),
              ),
            ],
          ),
    );
  }

  void _showFirstAidGuide(BuildContext context, String title) {
    String content = '';
    String doTitle = '';
    String dontTitle = '';
    List<String> doList = [];
    List<String> dontList = [];

    switch (title) {
      case 'Knocked-out Tooth':
        doTitle = 'DO: Save the tooth';
        dontTitle = "DON'T: Handle the root";
        doList = [
          'Pick up by the crown (chewing surface)',
          'Rinse gently with milk or saline if dirty',
          'Try to reinsert in socket if possible',
          'Keep moist in milk or saliva',
        ];
        dontList = [
          "Don't scrub or clean aggressively",
          "Don't let the tooth dry out",
          "Don't wrap in dry tissue",
        ];
        break;
      case 'Broken Tooth':
        doTitle = 'DO: Save pieces';
        dontTitle = "DON'T: Use sharp objects";
        doList = [
          'Rinse mouth with warm water',
          'Apply gauze if bleeding',
          'Use cold compress for swelling',
          'Save any broken pieces',
        ];
        dontList = [
          "Don't probe with sharp objects",
          "Don't chew on that side",
          "Don't ignore even if painless",
        ];
        break;
      // Add other cases similarly
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2541),
      isScrollControlled: true,
      builder:
          (context) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  doTitle,
                  style: TextStyle(
                    color: Colors.green[300],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...doList.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: Colors.green)),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  dontTitle,
                  style: TextStyle(
                    color: Colors.red[300],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...dontList.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: Colors.red)),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _launchEmergencyCall('18005559876'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('NEED MORE HELP? CALL DENTAL HOTLINE'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }
}
