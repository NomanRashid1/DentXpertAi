import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // 💡 New Import for X-Ray Upload
// Replace with your actual path, or keep it relative if correct:
import 'payment_screen.dart';

class AppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const AppointmentScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController issueController = TextEditingController();

  String? selectedTimeSlot;
  DateTime selectedDate = DateTime.now();
  File? _xrayImage;
  bool emergencySelected = false;
  String consultationMode = 'Online';
  bool _isSaving = false; // 💡 New: To prevent double-taps and show loading

  // Use 'timeSlots' or 'availableTimeSlots' consistently.
  // Based on your DentistRegistrationScreen, 'timeSlots' might be correct.
  List<String> get availableTimeSlots =>
      List<String>.from(widget.doctor['timeSlots'] ?? ['10:00 AM', '11:00 AM', '12:00 PM']);

  bool get isEmergencyAvailable => widget.doctor['offersEmergency'] == true;

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    issueController.dispose();
    super.dispose();
  }

  Future<void> _pickXrayImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _xrayImage = File(picked.path));
    }
  }

  // 🚀 New Function: Upload X-Ray to Firebase Storage
  Future<String?> _uploadXrayImage() async {
    if (_xrayImage == null) return null;

    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${widget.doctor['email']}_xray.jpg';
      final storageRef = FirebaseStorage.instance.ref().child('xrays/$fileName');

      // Upload the file
      final uploadTask = storageRef.putFile(_xrayImage!);
      final snapshot = await uploadTask.whenComplete(() {});

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;

    } on FirebaseException catch (e) {
      debugPrint('X-Ray upload failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload X-ray image.')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Book Appointment',
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDoctorCard(),
              const SizedBox(height: 20),
              _buildPatientInfoSection(),
              const SizedBox(height: 20),
              _buildAppointmentDetailsSection(context),
              const SizedBox(height: 20),
              _buildXrayUploadSection(),
              const SizedBox(height: 20),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Builders (Skipping redundant code for brevity, assumes they are correct) ---

  Widget _buildDoctorCard() {
    // ... (Your existing _buildDoctorCard code)
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF013A63), Color(0xFF026384)],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Dr. ${widget.doctor['name'] ?? 'Doctor Name'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    'PKR ${widget.doctor['charges'] ?? '0'}', // 💡 Use regular charges here
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.doctor['specialization'] ?? 'Specialization',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
            if (isEmergencyAvailable)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: const [
                    Icon(Icons.emergency, color: Colors.redAccent, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Emergency Available',
                        style: TextStyle(fontSize: 14, color: Colors.redAccent),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildPatientInfoSection() {
    // ... (Your existing _buildPatientInfoSection code)
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField('Your Name*', nameController),
            _buildTextField('Age*', ageController, keyboardType: TextInputType.number),
            _buildTextField('Phone Number*', phoneController, keyboardType: TextInputType.phone),
            _buildIssueField(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    // ... (Your existing _buildTextField code)
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.cyanAccent),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.cyanAccent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
          ),
        ),
        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildIssueField() {
    // ... (Your existing _buildIssueField code)
    return TextFormField(
      controller: issueController,
      maxLines: 3,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Describe Your Issue*',
        labelStyle: const TextStyle(color: Colors.cyanAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.cyanAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
        ),
      ),
      validator: (value) => value == null || value.trim().isEmpty ? 'Please describe your issue' : null,
    );
  }

  Widget _buildAppointmentDetailsSection(BuildContext context) {
    // ... (Your existing _buildAppointmentDetailsSection code)
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appointment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 12),
            _buildDatePicker(context),
            const SizedBox(height: 12),
            _buildTimeSlotDropdown(),
            const SizedBox(height: 12),
            _buildConsultationModeToggle(),
            if (isEmergencyAvailable) ...[
              const SizedBox(height: 12),
              _buildEmergencySwitch(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    // ... (Your existing _buildDatePicker code)
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                dialogBackgroundColor: const Color(0xFF001F3F),
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
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) setState(() => selectedDate = pickedDate);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.05), Colors.cyanAccent.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.cyanAccent, size: 20),
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

  Widget _buildTimeSlotDropdown() {
    // ... (Your existing _buildTimeSlotDropdown code)
    return DropdownButtonFormField<String>(
      value: selectedTimeSlot,
      dropdownColor: const Color(0xFF001F3F),
      decoration: InputDecoration(
        labelText: 'Select Time Slot*',
        labelStyle: const TextStyle(color: Colors.cyanAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.cyanAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
        ),
      ),
      items: availableTimeSlots
          .map((slot) => DropdownMenuItem(
        value: slot,
        child: Text(slot, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ))
          .toList(),
      onChanged: (val) => setState(() => selectedTimeSlot = val),
      validator: (val) => val == null ? 'Required' : null,
    );
  }

  Widget _buildConsultationModeToggle() {
    // ... (Your existing _buildConsultationModeToggle code)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consultation Mode',
          style: TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: _buildConsultationChip('Online')),
            const SizedBox(width: 12),
            Expanded(child: _buildConsultationChip('In-Person')),
          ],
        ),
      ],
    );
  }

  Widget _buildConsultationChip(String mode) {
    // ... (Your existing _buildConsultationChip code)
    final isSelected = consultationMode == mode;
    return ChoiceChip(
      label: Text(
        mode,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
      selected: isSelected,
      selectedColor: Colors.cyanAccent,
      backgroundColor: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.cyanAccent.withOpacity(0.5)),
      ),
      onSelected: (selected) {
        if (selected) setState(() => consultationMode = mode);
      },
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildEmergencySwitch() {
    // ... (Your existing _buildEmergencySwitch code)
    final emergencyCharges = widget.doctor['emergencyCharges'] ?? '0';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB00020), Color(0xFFEF5350)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Emergency Appointment',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: emergencySelected,
                onChanged: (val) => setState(() => emergencySelected = val),
                activeColor: Colors.yellowAccent,
                activeTrackColor: Colors.white,
              ),
            ],
          ),
          if (emergencySelected)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Emergency Charges: PKR $emergencyCharges',
                style: const TextStyle(
                  color: Colors.yellowAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildXrayUploadSection() {
    // ... (Your existing _buildXrayUploadSection code)
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Dental X-ray',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                onPressed: _pickXrayImage,
                icon: const Icon(Icons.cloud_upload_rounded, size: 20),
                label: const Text(
                  'Choose File',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
            if (_xrayImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _xrayImage!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      // Disable button while saving or if validation fails
      onPressed: _isSaving ? null : () async {
        if (!_formKey.currentState!.validate() || selectedTimeSlot == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please complete all required fields and select a time slot.')),
          );
          return;
        }

        setState(() => _isSaving = true); // Start loading

        try {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser == null) {
            throw Exception("User is not logged in.");
          }

          // 1. Upload X-Ray Image (if present)
          final String? xrayUrl = await _uploadXrayImage();

          // 2. Determine Final Charges
          final chargesKey = emergencySelected ? 'emergencyCharges' : 'charges';
          final finalCharges = widget.doctor[chargesKey] ?? '0';

          // 3. Prepare Appointment Data
          final appointmentData = {
            'doctor': widget.doctor, // Store full doctor data for easy access
            'doctorId': widget.doctor['email'],
            'patientName': nameController.text.trim(),
            'patientEmail': currentUser.email, // Use logged-in user email
            'patientId': currentUser.uid, // Use logged-in user UID
            'age': ageController.text.trim(),
            'phone': phoneController.text.trim(),
            'issue': issueController.text.trim(),
            'date': DateFormat('yyyy-MM-dd').format(selectedDate),
            'assignedTime': selectedTimeSlot,
            'consultationMode': consultationMode,
            'emergencySelected': emergencySelected,
            'xrayUrl': xrayUrl, // Store the uploaded URL
            'status': 'pending',
            'timestamp': DateTime.now(),
            'charges': finalCharges,
          };

          // 4. Save Appointment Data to Firestore
          final appointmentRef = await FirebaseFirestore.instance
              .collection('appointments')
              .add(appointmentData);

          // 5. Navigate to Payment Screen
          await Navigator.pushNamed(
            context,
            '/payment',
            arguments: {
              'appointmentId': appointmentRef.id,
              'appointmentData': appointmentData,
            },
          );

        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking failed: ${e.toString()}')),
          );
          debugPrint('Booking Error: $e');

        } finally {
          if(mounted) {
            setState(() => _isSaving = false); // Stop loading
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: _isSaving
          ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 2,
          )
      )
          : const Text(
        'Confirm & Pay',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}