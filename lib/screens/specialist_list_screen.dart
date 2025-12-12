import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// NOTE: Ensure your DoctorAppointmentScreen is correctly imported or referenced
// for the '/appointment' route, or replace the route name if necessary.

class SpecialistListScreen extends StatefulWidget {
  const SpecialistListScreen({super.key});

  @override
  _SpecialistListScreenState createState() => _SpecialistListScreenState();
}

class _SpecialistListScreenState extends State<SpecialistListScreen> {
  String _searchCity = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00172D),
      body: SafeArea(
        child: Column(
          children: [
            // Header (Unchanged)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00BCD4), Color(0xFF007B9E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Nearby Dental Specialists',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Find top-rated dentists near you and book appointments easily.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchCity = value.trim().toLowerCase();
                      });
                    },
                    style: const TextStyle(color: Colors.black),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: 'Search by city...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.cyanAccent.withValues(alpha: 0.4),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.cyanAccent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Dentist List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                FirebaseFirestore.instance
                    .collection('dentists')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),

                builder: (context, snapshot) {
                  // Handle loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.cyanAccent,
                      ),
                    );
                  }

                  // Handle errors (Crucial for debugging Permission Denied)
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        // This will show the Firebase error (like Permission Denied)
                        'Error loading dentists: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No dentists found.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final filteredDocs =
                  snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final city =
                    (data['clinicAddress'] ?? '')
                        .toString()
                        .toLowerCase();
                    return _searchCity.isEmpty ||
                        city.contains(_searchCity);
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No dentists match your search criteria.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final data =
                      filteredDocs[index].data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          // Navigate to detailed profile screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DoctorDetailScreen(data: data),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            border: Border.all(
                              color: Colors.cyanAccent.withValues(alpha: 0.2),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ... (Doctor Info display logic)
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 32,
                                    backgroundColor: Colors.cyanAccent,
                                    child: Icon(
                                      Icons.person,
                                      size: 32,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['name'] ?? 'Dr. Unknown',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          data['specialization'] ??
                                              'General Dentist',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          data['bio'] ?? 'No bio available.',
                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 13,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.attach_money,
                                        size: 20,
                                        color: Colors.cyanAccent,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        // The 'charges' field might be an int/num, but is likely a String here.
                                        // Still safe if it's already a string like 'PKR XXXX'
                                        '${data['charges'] ?? '0'} /hour',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Correctly navigate to the appointment screen, passing the doctor's data
                                      Navigator.pushNamed(
                                        context,
                                        '/appointment',
                                        arguments: {'doctor': data},
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                    ),
                                    label: const Text('Book'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyanAccent,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------------
// 🌟 FIX APPLIED HERE: DoctorDetailScreen
// --------------------------------------------------------------------------------

class DoctorDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const DoctorDetailScreen({super.key, required this.data});

  // 🎯 NEW: Helper function to safely convert dynamic Firestore data to String
  String _safeString(String key) {
    final value = data[key];
    if (value == null) return 'N/A';
    if (value is num) return value.toString();
    if (value is String) return value;
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00172D),
      appBar: AppBar(
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        title: Text(data['name'] ?? 'Doctor Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ... (Avatar and basic info)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withValues(alpha: 0.6),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.cyanAccent,
                child: Icon(Icons.person, size: 50, color: Colors.black),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              data['name'] ?? 'Dr. Unknown',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              data['specialization'] ?? 'Specialist',
              style: const TextStyle(color: Colors.cyanAccent, fontSize: 16),
            ),

            const SizedBox(height: 30),

            // Detail Cards (Using the safe helper function)
            _infoCard(
              Icons.badge,
              'Experience',
              // 🎯 FIXED LINE: Use _safeString to handle 'experience' (which is likely an int)
              '${_safeString('experience')} years',
            ),
            _infoCard(
              Icons.monetization_on,
              'Charges',
              // 🎯 FIXED LINE: Use _safeString to handle 'charges' (which might be an int/num)
              _safeString('charges'),
            ),
            _infoCard(Icons.business, 'Clinic', data['clinicName'] ?? ''),
            _infoCard(
              Icons.location_on,
              'Address',
              data['clinicAddress'] ?? '',
            ),
            _infoCard(Icons.phone, 'Contact', data['phone'] ?? ''),
            _infoCard(
              Icons.info_outline,
              'Bio',
              data['bio'] ?? 'No bio available',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'N/A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}