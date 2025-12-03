import 'package:flutter/material.dart';
import 'dart:ui'; // Required for BackdropFilter

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final bool isLinkSent; // We still use this to display the prompt

  const EmailVerificationScreen({
    super.key,
    required this.email,
    this.isLinkSent = false,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // 🚀 Updated Logic: Always navigate after a small delay if form is valid
  void _verifyCodeAndLogin() async {
    // Only validate the form structure (6 digits must be present)
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // --- SIMULATION STEP: Simulate network/loading time ---
    await Future.delayed(const Duration(milliseconds: 800));

    // --- SIMULATION SUCCESS: Directly navigate ---
    if (mounted) {
      // Navigate to the User Home Screen immediately
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/userHome', (route) => false);
    }
    // --- END SIMULATION ---

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove AppBar from Scaffold to integrate into Stack
      // Use the beautiful background from EmailSetupScreen
      body: Stack(
        children: [
          // 1. RADIAL GRADIENT BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.3),
                radius: 1.2,
                colors: [Color(0xFF083d77), Color(0xFF001e3c)],
                stops: [0.0, 1.0],
              ),
            ),
          ),

          // 2. Main Content (includes the custom AppBar space)
          SafeArea(
            child: SingleChildScrollView(
              child: Align(
                alignment: const Alignment(0.0, -0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 30.0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.cyanAccent.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title Section
                              const Icon(
                                Icons.vpn_key_rounded,
                                size: 60,
                                color: Colors.cyanAccent,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Enter Verification Code',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),

                              // Description
                              Text(
                                'A 6-digit code has been sent to:',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 5),

                              // Email Display
                              Text(
                                widget.email,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.cyanAccent,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),

                              // 6-Digit Code Input Field
                              TextFormField(
                                controller: _codeController,
                                keyboardType: TextInputType.number,
                                maxLength: 6, // Limit input to 6 digits
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  letterSpacing: 10,
                                ),
                                cursorColor: Colors.cyanAccent,
                                decoration: InputDecoration(
                                  hintText: '• • • • • •',
                                  hintStyle: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 24,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withValues(
                                    alpha: 0.1,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.cyanAccent,
                                      width: 2,
                                    ),
                                  ),
                                  counterText: '', // Hide the character counter
                                ),
                                validator: (value) {
                                  // We keep the validator to ensure the field is filled correctly before navigation
                                  if (value == null || value.length != 6) {
                                    return 'Code must be exactly 6 digits.';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 40),

                              // VERIFY & LOGIN Button
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton.icon(
                                  onPressed:
                                      _isLoading ? null : _verifyCodeAndLogin,
                                  icon:
                                      _isLoading
                                          ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.black,
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Icon(Icons.login),
                                  label: Text(
                                    _isLoading
                                        ? 'VERIFYING...'
                                        : 'VERIFY & LOGIN',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.cyanAccent,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Go Back Button
                              Center(
                                child: TextButton(
                                  onPressed:
                                      _isLoading
                                          ? null
                                          : () {
                                            Navigator.pop(context);
                                          },
                                  child: const Text(
                                    'Go Back to Email Input',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
