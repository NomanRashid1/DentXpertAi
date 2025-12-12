import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // 🎯 HTTP package ab use kiya ja sakta hai
import 'dart:async'; // Mock delay ke liye
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class PatientProfileScreen extends StatefulWidget {
  final Map<String, dynamic> appointmentData;
  // Note: main.dart se appointmentId bheja ja raha tha.
  final String appointmentId;

  const PatientProfileScreen({
    super.key,
    required this.appointmentData,
    // DoctorAppointmentsScreen se yeh ID aati hai (doc.id)
    required this.appointmentId,
  });

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  // === STATE VARIABLES FOR AI ANALYSIS ===
  bool _isLoading = false;
  String? _analysisResult;
  String? _errorMessage;
  String? _annotatedImageUrl; // Stores the URL of the processed image
  
  // Controller for Server IP (Default to Localhost via ADB Reverse)
  final TextEditingController _ipController = TextEditingController(text: "localhost");

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }
  // ======================================

  // 🎯 STEP 1: REAL AI ANALYSIS FUNCTION
  Future<void> _runAIAnalysis() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _analysisResult = null;
      _errorMessage = null;
      _annotatedImageUrl = null;
    });

    final xrayUrl = widget.appointmentData['xrayUrl'];
    final serverIp = _ipController.text.trim();

    if (xrayUrl == null || xrayUrl.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Cannot run analysis: X-ray URL is missing.";
      });
      return;
    }

    if (serverIp.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Please enter the Backend Server IP.";
      });
      return;
    }

    try {
      // 1. Download the Image from Firebase
      final imageResponse = await http.get(Uri.parse(xrayUrl));
      if (imageResponse.statusCode != 200) {
        throw Exception("Failed to download X-ray image from Firebase.");
      }

      // 2. Prepare Upload to Backend
      Uri uri;
      if (serverIp.contains('loca.lt')) {
        // Public Tunnel (HTTPS, No Port)
        uri = Uri.parse("https://$serverIp/api/predict");
      } else {
        // Local IP (HTTP, Port 5000)
        uri = Uri.parse("http://$serverIp:5000/api/predict");
      }
      
      var request = http.MultipartRequest('POST', uri);
      
      // Add file from bytes
      request.files.add(http.MultipartFile.fromBytes(
        'file', 
        imageResponse.bodyBytes,
        filename: 'xray_analysis.jpg' // Generic name, backend handles existing
      ));
      
      // Add confidence threshold
      request.fields['confidence_threshold'] = '0.25';


      // 3. Send Request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final results = data['results'];
          final uniqueId = results['unique_id'];
          final reportText = results['report']; // Full text report
          
          // Construct URL for annotated image
          // Backend returns local path, we need to convert to URL
          // e.g., "results_pridects\uuid.jpg" -> "http://IP:5000/api/image/uuid.jpg"
          // Construct URL for annotated image
          final outputImageFilename = "$uniqueId.jpg";
          String fullAnnotatedUrl;
          if (serverIp.contains('loca.lt')) {
             fullAnnotatedUrl = "https://$serverIp/api/image/$outputImageFilename";
          } else {
             fullAnnotatedUrl = "http://$serverIp:5000/api/image/$outputImageFilename";
          }

          setState(() {
            _analysisResult = reportText;
            _annotatedImageUrl = fullAnnotatedUrl;
          });
          
          // 🤖 AUTO-ACTION: Send Email Automatically
          // We use a slight delay to let UI update first
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) _sendEmailToPatient();
          });
          
        } else {
          throw Exception(data['error'] ?? "Unknown backend error");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode} - ${response.body}");
      }

    } catch (e) {
      setState(() {
        _errorMessage = "Analysis Failed: ${e.toString()}\n(Check connection to $serverIp:5000)";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  // 🎯 STEP 2: DOWNLOAD PDF REPORT (Start Save Logic)
  Future<void> _downloadReport() async {
    if (_analysisResult == null) return;
    
    try {
      setState(() => _isLoading = true);
      final serverIp = _ipController.text.trim();
      
      // Request Storage Permission
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          // Fallback check for Android 13+ (manage external storage or specific media permissions)
           // For simplicity in this fix, we will try to proceed or just warn
           if (await Permission.manageExternalStorage.status.isDenied) {
              // try requesting manage
           }
        }
      }

      // Determine URI
      Uri uri;
      if (serverIp.contains('loca.lt')) {
        uri = Uri.parse("https://$serverIp/api/predict-pdf");
      } else {
        uri = Uri.parse("http://$serverIp:5000/api/predict-pdf");
      }
      
      // We need to re-send the image to generate PDF on fly (simpler than storing state on stateless API)
      final xrayUrl = widget.appointmentData['xrayUrl'];
      final imageResponse = await http.get(Uri.parse(xrayUrl));
      
      var request = http.MultipartRequest('POST', uri);
      request.files.add(http.MultipartFile.fromBytes(
        'file', imageResponse.bodyBytes, filename: 'report.jpg'
      ));
      request.fields['confidence_threshold'] = '0.25';
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        // Save PDF to Public Downloads Folder
        Directory? downloadsDir;
        if (Platform.isAndroid) {
          downloadsDir = Directory('/storage/emulated/0/Download');
        } else {
          downloadsDir = await getDownloadsDirectory();
        }

        if (downloadsDir == null || !downloadsDir.existsSync()) {
             // Fallback to app documents
             downloadsDir = await getApplicationDocumentsDirectory();
        }

        final fileName = 'Dental_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${downloadsDir.path}/$fileName');
        
        await file.writeAsBytes(response.bodyBytes);
        
        // Open the file
        final result = await OpenFilex.open(file.path);
        
        String message = '✅ Saved to Downloads: $fileName';
        if (result.type != ResultType.done) {
            message = '✅ Saved to Downloads (Check File Manager)';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else {
        throw Exception("Server failed to generate PDF");
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Download Failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🎯 STEP 3: SEND EMAIL TO PATIENT
  Future<void> _sendEmailToPatient() async {
    if (_analysisResult == null) return;

    try {
      setState(() => _isLoading = true);
      final serverIp = _ipController.text.trim();
      
      Uri uri;
      if (serverIp.contains('loca.lt')) {
        uri = Uri.parse("https://$serverIp/api/send-email");
      } else {
        uri = Uri.parse("http://$serverIp:5000/api/send-email");
      }
      
      // 1. Get PDF first (re-using verify logic)
      final xrayUrl = widget.appointmentData['xrayUrl'];
      final imageResponse = await http.get(Uri.parse(xrayUrl));
      
      // Get PDF from Backend
      Uri pdfUri;
      if (serverIp.contains('loca.lt')) {
        pdfUri = Uri.parse("https://$serverIp/api/predict-pdf");
      } else {
        pdfUri = Uri.parse("http://$serverIp:5000/api/predict-pdf");
      }
       
      var pdfRequest = http.MultipartRequest('POST', pdfUri);
      pdfRequest.files.add(http.MultipartFile.fromBytes('file', imageResponse.bodyBytes, filename: 'xray.jpg'));
      final pdfStreamed = await pdfRequest.send();
      final pdfResponse = await http.Response.fromStream(pdfStreamed);
      
      if (pdfResponse.statusCode != 200) throw Exception("Failed to generate PDF for email");
      
      // 2. Send Email
      var emailRequest = http.MultipartRequest('POST', uri);
      // Backend expects 'file' for attachment
      emailRequest.files.add(http.MultipartFile.fromBytes(
        'file', 
        pdfResponse.bodyBytes, 
        filename: 'Dental_Report.pdf'
      ));
      
      emailRequest.fields['to_email'] = widget.appointmentData['patientEmail'] ?? 'test@example.com';
      emailRequest.fields['patient_name'] = widget.appointmentData['patientName'] ?? 'Patient';
      emailRequest.fields['age'] = widget.appointmentData['age'] ?? 'N/A';
      emailRequest.fields['gender'] = widget.appointmentData['gender'] ?? 'N/A';
      emailRequest.fields['contact'] = widget.appointmentData['phone'] ?? 'N/A';
      
      final emailStreamed = await emailRequest.send();
      final emailResponse = await http.Response.fromStream(emailStreamed);
      
      if (emailResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Email sent successfully!')),
        );
      } else {
        throw Exception("Email failed: ${emailResponse.body}");
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Email Failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final xrayUrl = widget.appointmentData['xrayUrl'];
    final hasXray = xrayUrl != null && xrayUrl.toString().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Patient Profile',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient Information Card
            _buildInfoCard(
              title: 'Patient Information',
              icon: Icons.person,
              children: [
                _buildInfoRow('Name', widget.appointmentData['patientName'] ?? 'N/A'),
                _buildInfoRow('Email', widget.appointmentData['patientEmail'] ?? 'N/A'),
                _buildInfoRow('Age', widget.appointmentData['age'] ?? 'N/A'),
                _buildInfoRow('Phone', widget.appointmentData['phone'] ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16),

            // Appointment Details Card
            _buildInfoCard(
              title: 'Appointment Details',
              icon: Icons.event_note,
              children: [
                _buildInfoRow('Date', widget.appointmentData['date'] ?? 'N/A'),
                _buildInfoRow('Time', widget.appointmentData['assignedTime'] ?? 'Not assigned'),
                _buildInfoRow('Mode', widget.appointmentData['consultationMode'] ?? 'N/A'),
                _buildInfoRow(
                  'Emergency',
                  widget.appointmentData['emergencySelected'] == true ? 'Yes' : 'No',
                ),
                _buildInfoRow('Status', (widget.appointmentData['status'] ?? 'pending').toUpperCase()),
              ],
            ),
            const SizedBox(height: 16),

            // Medical Issue Card
            _buildInfoCard(
              title: 'Medical Issue',
              icon: Icons.medical_services,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    widget.appointmentData['issue'] ?? 'No issue description provided',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // X-Ray Image Card
            if (_annotatedImageUrl != null)
              _buildXrayCard(_annotatedImageUrl!, title: "Analyzed X-Ray (Segmented)")
            else if (hasXray)
              _buildXrayCard(xrayUrl.toString())
            else
              _buildInfoCard(
                title: 'X-Ray Image',
                icon: Icons.image_not_supported,
                children: [
                   const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No X-ray image uploaded',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // 🎯 AI BUTTON SECTION (Agar X-ray ho toh dikhana)
            if (hasXray) _buildAIAnalysisSection(context),

            const SizedBox(height: 16),

            // 🎯 AI RESULT DISPLAY
            if (_isLoading) _buildLoadingCard(),
            if (_analysisResult != null) _buildResultCard(),
            if (_errorMessage != null) _buildErrorCard(),

            const SizedBox(height: 16),

            // Charges Card
            _buildInfoCard(
              title: 'Payment Information',
              icon: Icons.payments,
              children: [
                _buildInfoRow(
                  'Total Charges',
                  'PKR ${widget.appointmentData['charges'] ?? '0'}',
                  valueColor: const Color(0xFFFFD700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // === NEW WIDGETS FOR AI ===

  Widget _buildAIAnalysisSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.psychology, color: Colors.cyanAccent, size: 24),
              SizedBox(width: 8),
              Text(
                'AI Diagnostic Tool',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // IP Address Input
          TextField(
            controller: _ipController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Backend IP Address",
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: "e.g., 192.168.1.5",
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.computer, color: Colors.white60),
            ),
          ),
          const SizedBox(height: 16),
          
          ElevatedButton.icon(
            icon: _isLoading
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.flash_on, size: 20),
            label: Text(
              _isLoading ? 'Analyzing...' : 'Run AI Analysis',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: _isLoading ? null : _runAIAnalysis,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700), // Gold/Yellow for AI
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          if (_analysisResult != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download, size: 20),
                    label: const Text('Download PDF'),
                    onPressed: _isLoading ? null : _downloadReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black, 
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.email, size: 20),
                    label: const Text('Resend Email'),
                    onPressed: _isLoading ? null : _sendEmailToPatient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return _buildInfoCard(
      title: 'AI Analysis',
      icon: Icons.hourglass_empty,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Column(
              children: const [
                CircularProgressIndicator(color: Colors.cyanAccent),
                SizedBox(height: 12),
                Text(
                  'Analyzing X-ray image...',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    return _buildInfoCard(
      title: 'AI Analysis Results',
      icon: Icons.check_circle,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            _analysisResult ?? 'N/A',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return _buildInfoCard(
      title: 'AI Analysis Error',
      icon: Icons.error,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            _errorMessage ?? 'Unknown error occurred.',
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // === EXISTING WIDGETS (Helper Methods) ===

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
              children: [
                Icon(icon, color: Colors.cyanAccent, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.cyanAccent, thickness: 1),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildXrayCard(String imageUrl, {String title = 'Dental X-Ray'}) {
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
              children: [
                const Icon(Icons.image, color: Colors.cyanAccent, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.cyanAccent, thickness: 1),
            const SizedBox(height: 12),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.cyanAccent,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 48,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Failed to load X-ray image',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}