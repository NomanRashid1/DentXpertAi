import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

class UserAppointmentsScreen extends StatefulWidget {
  const UserAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<UserAppointmentsScreen> createState() => _UserAppointmentsScreenState();
}

class _UserAppointmentsScreenState extends State<UserAppointmentsScreen> {
  late String userEmail;
  bool showUpcoming = true;

  @override
  void initState() {
    super.initState();
    userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
  }

  Stream<QuerySnapshot> getAppointments() {
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('patientEmail', isEqualTo: userEmail)
        .where('status', isEqualTo: 'confirmed')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00172D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("🦷 My Appointments", style: TextStyle(color: Colors.cyanAccent, fontSize: 22, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.cyanAccent),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
            onPressed: () => setState(() {}),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          ToggleButtons(
            borderColor: Colors.cyanAccent,
            fillColor: Colors.cyanAccent.withOpacity(0.2),
            selectedBorderColor: Colors.cyanAccent,
            selectedColor: Colors.cyanAccent,
            borderRadius: BorderRadius.circular(10),
            isSelected: [showUpcoming, !showUpcoming],
            onPressed: (index) {
              setState(() => showUpcoming = index == 0);
            },
            children: const [
              Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Upcoming")),
              Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Past")),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Shimmer.fromColors(
                        baseColor: Colors.white10,
                        highlightColor: Colors.white24,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 64, color: Colors.white24),
                        SizedBox(height: 12),
                        Text("No appointments found.", style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  );
                }

                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);

                final filtered = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final apptDate = DateFormat('yyyy-MM-dd').parse(data['date']);
                  return showUpcoming ? !apptDate.isBefore(today) : apptDate.isBefore(today);
                }).toList();


                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      showUpcoming ? 'No upcoming appointments.' : 'No past appointments.',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final data = filtered[index].data() as Map<String, dynamic>;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF003D5B), Color(0xFF00172D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text("👨‍⚕️ Dr. ${data['doctorName']}",
                                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text("Confirmed", style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text("📅 Date: ${data['date']}", style: const TextStyle(color: Colors.white70)),
                          if (data['assignedTime'] != null)
                            Text("⏰ Time: ${data['assignedTime']}", style: const TextStyle(color: Colors.white70)),
                          Text("💬 Visit Type: ${data['visitType']}", style: const TextStyle(color: Colors.white60)),
                          const SizedBox(height: 6),

                          if (data['xrayUrl'] != null && data['xrayUrl'].toString().isNotEmpty)
                            TextButton.icon(
                              onPressed: () => showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(data['xrayUrl']),
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.image, color: Colors.cyanAccent),
                              label: const Text("View X-ray", style: TextStyle(color: Colors.cyanAccent)),
                            ),

                          if (showUpcoming &&
                              data['videoLink'] != null &&
                              data['videoLink'].toString().isNotEmpty)



                            GestureDetector(
                              onTap: () async {
                                final uri = Uri.parse(data['videoLink']);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Unable to open video call link")),
                                  );
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],

                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyanAccent.withOpacity(0.6),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.videocam, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text("Join Video Call",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
