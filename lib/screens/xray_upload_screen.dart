import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class XrayUploadScreen extends StatefulWidget {
  @override
  _XrayUploadScreenState createState() => _XrayUploadScreenState();
}

class _XrayUploadScreenState extends State<XrayUploadScreen> {
  File? _xrayImage;
  bool _isAnalyzing = false;
  bool _isXrayVerified = false;
  bool _showValidationResult = false;

  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  String gender = 'Male';
  String pain = 'No';
  String? painLocation;
  String duration = '1–2 days';
  String visitedDentist = 'No';

  final List<String> imageKeywords = ['xray', 'x-ray', 'tooth', 'teeth', 'dental'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF001F3F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.cyanAccent),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Upload Dental X-ray',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                _glassCard(
                  title: "PATIENT INFORMATION",
                  children: [
                    _textField(nameController, "Full Name (optional)"),
                    _textField(ageController, "Age", isNumber: true, required: true),
                    _dropdown("Gender", ["Male", "Female", "Other"], gender, (v) => setState(() => gender = v!)),
                    _dropdown("Do you have pain?", ["Yes", "No"], pain, (v) {
                      setState(() {
                        pain = v!;
                        if (pain == 'No') painLocation = null;
                      });
                    }),
                    if (pain == 'Yes')
                      _dropdown("Pain Location", ["Top", "Bottom", "Left", "Right"], painLocation, (v) => setState(() => painLocation = v)),
                    _dropdown("Pain Duration", ["1–2 days", "1 week", "2 weeks", "1 month"], duration, (v) => setState(() => duration = v!)),
                    _dropdown("Visited dentist recently?", ["Yes", "No"], visitedDentist, (v) => setState(() => visitedDentist = v!)),
                  ],
                ),

                _glassCard(
                  title: "UPLOAD X-RAY",
                  children: [
                    _xrayImage == null
                        ? Column(
                      children: [
                        Icon(Icons.upload, size: 60, color: Colors.white54),
                        SizedBox(height: 10),
                        Text("Tap to upload X-ray", style: TextStyle(color: Colors.white70)),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_xrayImage!, height: 200, fit: BoxFit.cover),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickXrayImage,
                      child: Text(_xrayImage == null ? "Select Image" : "Change Image"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    if (_isAnalyzing) ...[
                      SizedBox(height: 16),
                      CircularProgressIndicator(color: Colors.cyanAccent),
                      SizedBox(height: 8),
                      Text("Verifying image...", style: TextStyle(color: Colors.white70)),
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
                            SizedBox(width: 8),
                            Text(
                              _isXrayVerified ? 'Valid X-ray' : 'Invalid file. Upload a real X-ray.',
                              style: TextStyle(
                                color: _isXrayVerified ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isXrayVerified && _formKey.currentState!.validate()
                      ? _analyzeXray
                      : null,
                  child: Text("ANALYZE X-RAY", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isXrayVerified ? Colors.cyanAccent : Colors.grey,
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassCard({required String title, required List<Widget> children}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    )),
                SizedBox(height: 12),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label,
      {bool isNumber = false, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (required && (value == null || value.isEmpty)) return 'Required';
          return null;
        },
      ),
    );
  }

  Widget _dropdown(String label, List<String> options, String? currentValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        dropdownColor: Color(0xFF033053),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        style: TextStyle(color: Colors.white),
        items: options.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
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
        });

        await Future.delayed(Duration(seconds: 2));

        final fileName = picked.name.toLowerCase();
        final valid = (fileName.endsWith('.jpg') || fileName.endsWith('.png')) &&
            imageKeywords.any((k) => fileName.contains(k));

        setState(() {
          _isAnalyzing = false;
          _isXrayVerified = valid;
          _showValidationResult = true;
        });

        if (!valid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("⚠️ Invalid file. Upload a dental X-ray."), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

  void _analyzeXray() {
    Navigator.pushNamed(context, '/aiResults', arguments: {
      'xrayImage': _xrayImage!.path,
      'name': nameController.text,
      'age': ageController.text,
      'gender': gender,
      'pain': pain,
      'location': painLocation ?? 'None',
      'duration': duration,
      'visited': visitedDentist,
    });
  }
}
