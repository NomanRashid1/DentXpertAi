import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🚨 REQUIRED IMPORT
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'dart:io';

class DentistRegistrationScreen extends StatefulWidget {
  const DentistRegistrationScreen({super.key});

  @override
  _DentistRegistrationScreenState createState() =>
      _DentistRegistrationScreenState();
}

class _DentistRegistrationScreenState extends State<DentistRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Controllers ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _clinicNameController = TextEditingController();
  final TextEditingController _clinicAddressController =
  TextEditingController();
  final TextEditingController _chargesController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emergencyChargesController =
  TextEditingController();

  bool offersEmergency = false;
  List<String> timeSlots = [];
  bool _isLoading = false;

  File? _frontCardImage;
  File? _backCardImage;
  String? _selectedSpecialization;

  final List<String> specializations = [
    'Orthodontist',
    'Endodontist',
    'Prosthodontist',
    'Periodontist',
    'Oral Surgeon',
    'Pediatric Dentist',
    'Cosmetic Dentist',
    'General Dentist',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _experienceController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _chargesController.dispose();
    _bioController.dispose();
    _emergencyChargesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (type == 'front') {
          _frontCardImage = File(pickedFile.path);
        } else if (type == 'back') {
          _backCardImage = File(pickedFile.path);
        }
      });
    }
  }

  // 🚀 CORRECTED Firebase Submission Logic
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_frontCardImage == null || _backCardImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please upload both front and back license card images",
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final String name = _nameController.text;
    final String specialization = _selectedSpecialization ?? 'General Dentist';
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    try {
      // 1. 🔑 CREATE FIREBASE AUTH USER FIRST
      final UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = userCredential.user!.uid;

      // 2. Prepare data for Firestore (DO NOT include the password field)
      final Map<String, dynamic> dentistData = {
        'uid': uid, // 🚨 Store the secure User ID
        'name': name,
        'email': email,
        'specialization': specialization,
        'experience': int.tryParse(_experienceController.text) ?? 0,
        'charges': 'PKR ${_chargesController.text}',
        'bio': _bioController.text,
        'clinicAddress': _clinicAddressController.text,
        'clinicName': _clinicNameController.text,
        'phone': _phoneController.text,
        'offersEmergency': offersEmergency,
        'emergencyCharges': offersEmergency
            ? ('PKR ${_emergencyChargesController.text}')
            : null,
        'timeSlots': timeSlots,
        'isApproved': false, // Requires admin approval before login
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 3. Save data to the 'dentists' collection, using UID as document ID
      await FirebaseFirestore.instance.collection('dentists').doc(uid).set(dentistData);

      // 4. ✅ Navigate to the Success Screen
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/registrationSuccess',
          arguments: {'name': name, 'specialization': specialization},
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration failed: ${e.message}"),
          backgroundColor: Colors.red,
        ),
      );
    } on FirebaseException catch (e) {
      // If Auth user was created but Firestore failed, you might want to delete the Auth user too.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Database submission failed: ${e.message}. Check Firestore Rules.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ----------------------------------------------------------------------------------
  // 🎯 FIX LOCATION: The following methods must be correctly placed inside the State class
  // ----------------------------------------------------------------------------------

  Future<void> _showTimeSlotDialog() async {
    final List<String> availableSlots = [
      "9:00 AM",
      "9:30 AM",
      "10:00 AM",
      "10:30 AM",
      "11:00 AM",
      "11:30 AM",
      "12:00 PM",
      "12:30 PM",
      "2:00 PM",
      "2:30 PM",
      "3:00 PM",
      "3:30 PM",
      "4:00 PM",
      "4:30 PM",
      "5:00 PM",
      "5:30 PM",
    ];

    String? selectedSlot;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        backgroundColor: const Color(0xFF04152D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Select Time Slot",
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropdownButtonFormField<String>(
              value: selectedSlot,
              items:
              availableSlots.map((slot) {
                return DropdownMenuItem(
                  value: slot,
                  child: Text(
                    slot,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedSlot = val),
              decoration: const InputDecoration(
                hintText: "Choose a time",
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.cyanAccent,
                    width: 2,
                  ),
                ),
              ),
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (selectedSlot != null &&
                  !timeSlots.contains(selectedSlot)) {
                setState(() => timeSlots.add(selectedSlot!));
              }
              Navigator.pop(context);
            },
            child: const Text(
              "Add",
              style: TextStyle(color: Colors.cyanAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
      String label,
      TextEditingController controller, {
        bool isPassword = false,
        bool isNumeric = false,
        int? maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.transparent,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.cyanAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
          ),
        ),
        validator: (value) {
          if (label.toLowerCase().contains('email')) {
            if (value == null || value.isEmpty) {
              return 'Email is required';
            }
            final emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
            final regex = RegExp(emailPattern);
            if (!regex.hasMatch(value)) {
              return 'Enter a valid email like example@gmail.com';
            }
          } else if (label.toLowerCase().contains('password')) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            final passwordPattern =
                r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$';
            final regex = RegExp(passwordPattern);
            if (!regex.hasMatch(value)) {
              return 'Include at least 1 letter, 1 number & 1 symbol';
            }
          } else {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImagePicker(String label, File? imageFile, String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _pickImage(type),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.cyanAccent.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child:
              imageFile == null
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      color: Colors.cyanAccent,
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Upload Image',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                  height: 120,
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 FIX LOCATION: This function must be inside the State class.
  Widget buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Dentist Registration',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          // --- Personal Details ---
          _buildFormField('Full Name', _nameController),
          _buildFormField('Email', _emailController),
          _buildFormField('Password', _passwordController, isPassword: true),
          IntlPhoneField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.transparent,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.cyanAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.cyanAccent,
                  width: 2,
                ),
              ),
            ),
            initialCountryCode: 'PK',
            onChanged: (phone) {
              // Optional: Update phone number logic here
            },
            onSaved: (phone) {
              _phoneController.text = phone?.completeNumber ?? '';
            },
          ),
          _buildFormField(
            'CNIC / License No.',
            _cnicController,
            isNumeric: true,
          ),

          // --- License Images ---
          _buildImagePicker('Front License Card', _frontCardImage, 'front'),
          _buildImagePicker('Back License Card', _backCardImage, 'back'),

          // --- Professional Details ---
          _buildFormField(
            'Experience (years)',
            _experienceController,
            isNumeric: true,
          ),

          DropdownButtonFormField<String>(
            value: _selectedSpecialization,
            items:
            specializations.map((spec) {
              return DropdownMenuItem(
                value: spec,
                child: Text(
                  spec,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged:
                (value) => setState(() => _selectedSpecialization = value),
            decoration: InputDecoration(
              labelText: 'Specialization',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.cyanAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.cyanAccent,
                  width: 2,
                ),
              ),
            ),
            dropdownColor: const Color(0xFF04152D),
            style: const TextStyle(color: Colors.white),
            validator:
                (value) =>
            value == null ? 'Please select a specialization' : null,
          ),

          // --- Clinic Details ---
          _buildFormField('Clinic Name', _clinicNameController),
          _buildFormField('Clinic Address', _clinicAddressController),
          _buildFormField('Charges (PKR)', _chargesController, isNumeric: true),
          _buildFormField('Short Bio', _bioController, maxLines: 3),

          // --- Emergency Toggle ---
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Colors.cyanAccent.withValues(alpha: 0.2),
                  Colors.white10,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.cyanAccent, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_hospital_rounded,
                      color: Colors.cyanAccent,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Offers Emergency Appointments',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Switch(
                      value: offersEmergency,
                      onChanged: (val) => setState(() => offersEmergency = val),
                      activeColor: Colors.cyanAccent,
                      activeTrackColor: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (offersEmergency)
                  _buildFormField(
                    'Emergency Charges (PKR)',
                    _emergencyChargesController,
                    isNumeric: true,
                  ),
              ],
            ),
          ),

          // --- Time Slots ---
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: _showTimeSlotDialog,
              icon: const Icon(Icons.access_time, size: 20),
              label: const Text(
                'Add Available Time Slot',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
              ),
            ),
          ),
          if (timeSlots.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children:
                timeSlots.map((slot) {
                  return Chip(
                    label: Text(
                      slot,
                      style: const TextStyle(color: Colors.black),
                    ),
                    backgroundColor: Colors.cyanAccent.withValues(
                      alpha: 0.8,
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 18,
                    ),
                    onDeleted: () => setState(() => timeSlots.remove(slot)),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 24),

          // --- Submit Button ---
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm, // Disable when loading
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              shadowColor: Colors.cyanAccent.withValues(alpha: 0.4),
            ),
            child: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 3,
              ),
            )
                : const Text(
              'SUBMIT REGISTRATION',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
        title: const Text(
          'Dentist Registration',
          style: TextStyle(
            color: Colors.cyanAccent,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF001F3F), Color(0xFF003B73)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Center(
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white.withValues(alpha: 0.05),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.cyanAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: buildForm(), // 🎯 Calling the correctly located method
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}