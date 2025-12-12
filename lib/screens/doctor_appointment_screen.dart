import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  final String doctorEmail;

  const DoctorAppointmentsScreen({super.key, required this.doctorEmail});

  String generateVideoCallLink(String appointmentId) {
    return "https://meet.jit.si/dentxpert_$appointmentId";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Appointments',
          style: TextStyle(
            color: Colors.cyanAccent,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorId', isEqualTo: doctorEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Colors.white30,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Appointments Found',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final appointment = doc.data() as Map<String, dynamic>;

              // Controllers need to be managed locally or statefully if needed for updates
              final timeController = TextEditingController(
                text: appointment['assignedTime'] ?? "",
              );
              final reasonController = TextEditingController();

              DateTime selectedDate =
                  DateTime.tryParse(appointment['date'] ?? '') ??
                      DateTime.now();
              final link = appointment['videoLink'];
              final status = appointment['status'] ?? 'pending';

              // 🛠️ FIX 1: Add GestureDetector for navigation
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/patientProfile',
                    arguments: {
                      'appointmentData': appointment,
                      'appointmentId': doc.id, // Appointment ID bheja ja raha hai
                    },
                  );
                },
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.transparent,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: status == 'confirmed'
                            ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                            : status == 'rejected'
                            ? [const Color(0xFFB71C1C), const Color(0xFFC62828)]
                            : [const Color(0xFF013A63), const Color(0xFF026384)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.person,
                                  color: Colors.cyanAccent,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Patient Information',
                                  style: TextStyle(
                                    color: Colors.cyanAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: status == 'confirmed'
                                    ? Colors.greenAccent
                                    : status == 'rejected'
                                    ? Colors.redAccent
                                    : Colors.orangeAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('👤 Name', appointment['patientName'] ?? 'N/A'),
                        const SizedBox(height: 8),
                        _buildInfoRow('📧 Email', appointment['patientEmail'] ?? 'N/A'),
                        const SizedBox(height: 8),
                        _buildInfoRow('📞 Phone', appointment['phone'] ?? 'N/A'),
                        const SizedBox(height: 8),
                        _buildInfoRow('🦷 Issue', appointment['issue'] ?? 'N/A', maxLines: 2),
                        const SizedBox(height: 8),
                        _buildInfoRow('💰 Charges', 'PKR ${appointment['charges'] ?? 'N/A'}'),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.cyanAccent, thickness: 1),

                        if (status == 'pending') ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Schedule Appointment',
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Note: This Date Picker should ideally be wrapped in a StatefulWidget
                          // to update selectedDate instantly within the card,
                          // but we are keeping the existing structure for minimal disruption.
                          _buildDatePicker(context, selectedDate, (picked) {
                            selectedDate = picked;
                          }),
                          const SizedBox(height: 12),
                          TextField(
                            controller: timeController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Assign Time (e.g., 2:00 PM)',
                              labelStyle: const TextStyle(color: Colors.cyanAccent),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.cyanAccent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.cyanAccent.withOpacity(0.5),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: reasonController,
                            maxLines: 2,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Reason for Rejection (optional)',
                              labelStyle: const TextStyle(color: Colors.redAccent),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.redAccent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.redAccent.withOpacity(0.5),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.check, size: 20),
                                  label: const Text(
                                    'Confirm',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (timeController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please assign a time'),
                                          backgroundColor: Colors.orangeAccent,
                                        ),
                                      );
                                      return;
                                    }

                                    final videoLink = generateVideoCallLink(doc.id);
                                    await FirebaseFirestore.instance
                                        .collection('appointments')
                                        .doc(doc.id)
                                        .update({
                                      'assignedTime': timeController.text.trim(),
                                      'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                                      'videoLink': videoLink,
                                      'status': 'confirmed',
                                    });

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('✅ Appointment Confirmed'),
                                          backgroundColor: Colors.greenAccent,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.cyanAccent,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.cancel, size: 20),
                                  label: const Text(
                                    'Reject',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('appointments')
                                        .doc(doc.id)
                                        .update({
                                      'status': 'rejected',
                                      'rejectionReason': reasonController.text.trim(),
                                    });

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('❌ Appointment Rejected'),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Appointment Details',
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow('📆 Date', appointment['date'] ?? 'N/A'),
                          const SizedBox(height: 8),
                          _buildInfoRow('⏰ Time', appointment['assignedTime'] ?? 'Not assigned'),
                          if (status == 'rejected' && appointment['rejectionReason'] != null) ...[
                            const SizedBox(height: 8),
                            _buildInfoRow('❌ Reason', appointment['rejectionReason'], maxLines: 3),
                          ],
                          if (link != null && status == 'confirmed') ...[
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.video_call, size: 20),
                              label: const Text(
                                'Start Video Call',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () => launchUrl(Uri.parse(link!)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: maxLines,
          ),
        ),
      ],
    );
  }

  // 🛠️ FIX 2: Updated DialogTheme to DialogThemeData
  Widget _buildDatePicker(BuildContext context, DateTime selectedDate, Function(DateTime) onDateChanged) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.cyanAccent,
                onPrimary: Colors.black,
                surface: Color(0xFF001F3F),
                onSurface: Colors.white,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.cyanAccent,
                ),
              ),
              // FIX: Using DialogThemeData
              dialogTheme: const DialogThemeData(
                backgroundColor: Color(0xFF001F3F),
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          onDateChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.05),
              Colors.cyanAccent.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: Colors.cyanAccent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Date: ${DateFormat('EEE, MMM d, yyyy').format(selectedDate)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}