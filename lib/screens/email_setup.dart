import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class EmailSetupScreen extends StatefulWidget {
  const EmailSetupScreen({super.key});

  @override
  State<EmailSetupScreen> createState() => _EmailSetupScreenState();
}

class _EmailSetupScreenState extends State<EmailSetupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Generate a random 6-digit code
  String _generateCode() {
    final random = Random();
    return (random.nextInt(900000) + 100000).toString();
  }

  // Send verification code
  Future<void> _sendVerificationCode() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();

    final code = _generateCode();
    final expirationTime = DateTime.now().add(const Duration(minutes: 5));

    try {
      print('🚀 Attempting to write to Firestore...');
      print('📧 Email: $email');
      print('🔢 Code: $code');

      await FirebaseFirestore.instance.collection('emailVerificationCodes').doc(email).set({
        'email': email,
        'code': code,
        'expiresAt': Timestamp.fromMillisecondsSinceEpoch(expirationTime.millisecondsSinceEpoch),
        'sentAt': FieldValue.serverTimestamp(),
      });

      print('✅ Firestore write successful!');

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/emailVerification',
          arguments: {
            'email': email,
            'isLinkSent': true,
          },
        );
      }

    } catch (e, stackTrace) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ERROR: ${e.toString()}'),
            duration: const Duration(seconds: 8),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('═══════════════════════════════════');
      print('❌ FIRESTORE ERROR: $e');
      print('❌ ERROR TYPE: ${e.runtimeType}');
      print('❌ STACK TRACE: $stackTrace');
      print('═══════════════════════════════════');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 🧪 TEST BUTTON - Test Firestore connection
  Future<void> _testFirestore() async {
    try {
      print('🧪 Testing Firestore write...');

      await FirebaseFirestore.instance
          .collection('emailVerificationCodes')
          .doc('test@test.com')
          .set({
        'email': 'test@test.com',
        'code': '123456',
        'expiresAt': Timestamp.now(),
        'sentAt': FieldValue.serverTimestamp(),
      });

      print('✅ Firestore write SUCCESSFUL!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Firestore works! Check console for details.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

    } catch (e, stackTrace) {
      print('═══════════════════════════════════');
      print('❌ TEST ERROR: $e');
      print('❌ ERROR TYPE: ${e.runtimeType}');
      print('❌ STACK: $stackTrace');
      print('═══════════════════════════════════');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text('Sign In / Sign Up'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enter your Email Address',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'We will send a 6-digit verification code to your email.',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email Input Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.cyanAccent),
                    filled: true,
                    fillColor: Color(0xFF1C2849),
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Send Code Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendVerificationCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'SEND VERIFICATION CODE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🧪 DEBUG TEST BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _testFirestore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '🧪 TEST FIRESTORE CONNECTION',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  '👆 Press test button first to check Firestore',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}