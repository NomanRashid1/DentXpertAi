import 'package:flutter/material.dart';
// Removed: import 'package:firebase_auth/firebase_auth.dart';
// Removed: import 'dart:async';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final bool isLinkSent; // We still use this to display the prompt

  const EmailVerificationScreen({
    Key? key,
    required this.email,
    this.isLinkSent = false,
  }) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
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
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/userHome',
            (route) => false,
      );
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
      backgroundColor: const Color(0xFF001e3c),
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
        automaticallyImplyLeading: false, // Prevent back button
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.vpn_key_rounded,
                  size: 80,
                  color: Colors.cyanAccent,
                ),
                const SizedBox(height: 30),

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

                Text(
                  'A 6-digit code has been sent to:',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),

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
                      color: Colors.white, fontSize: 24, letterSpacing: 10),
                  cursorColor: Colors.cyanAccent,
                  decoration: InputDecoration(
                    hintText: '• • • • • •',
                    hintStyle: TextStyle(color: Colors.white54, fontSize: 24),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
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
                    onPressed: _isLoading ? null : _verifyCodeAndLogin,
                    icon: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : const Icon(Icons.login),
                    label: Text(
                      _isLoading ? 'VERIFYING...' : 'VERIFY & LOGIN',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextButton(
                  onPressed: _isLoading ? null : () {
                    // Allow user to go back to the input screen
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Go Back to Email Input',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}