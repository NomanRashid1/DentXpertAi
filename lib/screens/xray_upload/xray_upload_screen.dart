import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/patient_model.dart';
import 'results_screen.dart';
import 'services/api_service.dart';
import 'services/config_service.dart';
import 'services/dio_service.dart';
import 'widgets/custom_form_field.dart';
import 'widgets/glass_card.dart';
import 'widgets/loading_indicator.dart';

class XrayUploadScreen extends StatefulWidget {
  const XrayUploadScreen({super.key});

  @override
  _XrayUploadScreenState createState() => _XrayUploadScreenState();
}

class _XrayUploadScreenState extends State<XrayUploadScreen> {
  File? _xrayImage;
  bool _isAnalyzing = false;
  bool _isXrayVerified = false;
  bool _showValidationResult = false;
  bool _isProcessing = false;
  bool _isSendingEmail = false;
  String? _errorMessage;

  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _dioService = DioService();
  final _apiService = ApiService();

  // Form controllers
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();

  // Dropdown values
  String gender = 'Male';
  String pain = 'No';
  String? painLocation;
  String duration = '1–2 days';
  String visitedDentist = 'No';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // Patient Information
                    GlassCard(
                      title: "PATIENT INFORMATION",
                      children: _buildPatientInfoFields(),
                    ),

                    // Email Section
                    GlassCard(
                      title: "REPORT DELIVERY",
                      children: _buildEmailSection(),
                    ),

                    // Upload X-ray
                    GlassCard(
                      title: "UPLOAD X-RAY",
                      children: _buildUploadSection(),
                    ),

                    // Error Message
                    if (_errorMessage != null) _buildErrorMessage(),

                    const SizedBox(height: 20),

                    // Analyze Button
                    _buildAnalyzeButton(),
                  ],
                ),
              ),
            ),

            // Loading Overlay
            if (_isProcessing || _isSendingEmail) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppConfig.accentColor),
          onPressed: () => Navigator.pop(context),
        ),
        const Text(
          'Upload Dental X-ray',
          style: TextStyle(
            color: AppConfig.accentColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPatientInfoFields() {
    return [
      CustomTextField(
        controller: nameController,
        label: "Full Name (optional)",
      ),
      CustomTextField(
        controller: ageController,
        label: "Age",
        isNumber: true,
        required: true,
      ),
      CustomDropdown(
        label: "Gender",
        options: const ["Male", "Female", "Other"],
        value: gender,
        onChanged: (v) => setState(() => gender = v!),
      ),
      CustomDropdown(
        label: "Do you have pain?",
        options: const ["Yes", "No"],
        value: pain,
        onChanged: (v) {
          setState(() {
            pain = v!;
            if (pain == 'No') painLocation = null;
          });
        },
      ),
      if (pain == 'Yes')
        CustomDropdown(
          label: "Pain Location",
          options: const ["Top", "Bottom", "Left", "Right"],
          value: painLocation,
          onChanged: (v) => setState(() => painLocation = v),
        ),
      CustomDropdown(
        label: "Pain Duration",
        options: const ["1–2 days", "1 week", "2 weeks", "1 month"],
        value: duration,
        onChanged: (v) => setState(() => duration = v!),
      ),
      CustomDropdown(
        label: "Visited dentist recently?",
        options: const ["Yes", "No"],
        value: visitedDentist,
        onChanged: (v) => setState(() => visitedDentist = v!),
      ),
    ];
  }

  List<Widget> _buildUploadSection() {
    return [
      _xrayImage == null
          ? Column(
            children: [
              Icon(Icons.upload, size: 60, color: Colors.white54),
              const SizedBox(height: 10),
              const Text(
                "Tap to upload X-ray",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          )
          : ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(_xrayImage!, height: 200, fit: BoxFit.cover),
          ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: _pickXrayImage,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.accentColor,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(_xrayImage == null ? "Select Image" : "Change Image"),
      ),
      if (_isAnalyzing) ...[
        const SizedBox(height: 16),
        const CircularProgressIndicator(color: AppConfig.accentColor),
        const SizedBox(height: 8),
        const Text(
          "Verifying image...",
          style: TextStyle(color: Colors.white70),
        ),
      ],
      if (_showValidationResult)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isXrayVerified ? Icons.check_circle : Icons.error,
                color: _isXrayVerified ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                _isXrayVerified
                    ? 'Valid X-ray'
                    : 'Invalid file. Upload a dental X-ray.',
                style: TextStyle(
                  color: _isXrayVerified ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
    ];
  }

  List<Widget> _buildEmailSection() {
    return [
      CustomTextField(
        controller: emailController,
        label: "Email Address",
        isEmail: true,
        required: true,
      ),
      const SizedBox(height: 8),
      Text(
        "The analysis report will be sent to this email",
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    ];
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return ElevatedButton(
      onPressed:
          _isXrayVerified && _formKey.currentState!.validate()
              ? () => _analyzeXrayAndSendEmail()
              : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isXrayVerified ? AppConfig.accentColor : Colors.grey,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        _isXrayVerified ? "ANALYZE X-RAY & SEND REPORT" : "UPLOAD X-RAY FIRST",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: LoadingIndicator(
          message:
              _isProcessing
                  ? 'Analyzing X-ray and generating report...'
                  : 'Sending report to email...',
        ),
      ),
    );
  }

  Future<void> _pickXrayImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _xrayImage = File(picked.path);
          _isAnalyzing = true;
          _isXrayVerified = false;
          _showValidationResult = false;
          _errorMessage = null;
        });

        // Validate image
        final isValid = _apiService.validateImage(_xrayImage!);

        setState(() {
          _isAnalyzing = false;
          _isXrayVerified = isValid;
          _showValidationResult = true;
        });

        if (!isValid) {
          setState(() {
            _errorMessage = "⚠️ Please upload a valid dental X-ray image";
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  Future<void> _analyzeXrayAndSendEmail() async {
    if (!_isXrayVerified || _xrayImage == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Create patient object
      final patient = Patient(
        name: nameController.text.isNotEmpty ? nameController.text : null,
        age: ageController.text,
        gender: gender,
        pain: pain,
        painLocation: painLocation,
        duration: duration,
        visitedDentist: visitedDentist,
        email: emailController.text.trim(),
        xrayImage: _xrayImage,
      );

      // Step 1: Send to API for analysis
      final pdfBytes = await _apiService.analyzeXray(
        imageFile: _xrayImage!,
        confidenceThreshold: 0.25,
      );

      setState(() {
        _isProcessing = false;
        _isSendingEmail = true;
      });

      // Step 2: Send email via backend API
      final emailResult = await _dioService.sendEmailWithPdf(
        pdfBytes: pdfBytes,
        toEmail: patient.email,
        patientName: patient.name ?? 'Patient',
        age: patient.age,
        gender: patient.gender,
        contact: patient.email,
        pdfFilename:
            'dental_report_${patient.name ?? DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (!emailResult['success']) {
        // Email failed but continue to show results
        print('Email failed: ${emailResult['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ Report generated but email failed: ${emailResult['message']}',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // Step 3: Navigate to results
      _navigateToResultsScreen(patient, pdfBytes);
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _isSendingEmail = false;
        _errorMessage = "Error: ${e.toString()}";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _navigateToResultsScreen(Patient patient, Uint8List pdfBytes) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ResultsScreen(
              patient: patient,
              pdfBytes: pdfBytes,
              emailSent: true,
            ),
      ),
    );
  }
}
