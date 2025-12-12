import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final bool isLinkSent;

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
  int _resendTimerSeconds = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    if (widget.isLinkSent) {
      _startResendTimer();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimerSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimerSeconds == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _resendTimerSeconds--;
        });
      }
    });
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: Duration(seconds: isError ? 5 : 3),
        ),
      );
    }
  }

  String _generateNewCode() {
    final random = Random();
    return (random.nextInt(900000) + 100000).toString();
  }

  Future<void> _resendCode() async {
    if (_resendTimerSeconds > 0 || _isLoading) return;

    setState(() => _isLoading = true);
    final email = widget.email;
    final code = _generateNewCode();
    final expirationTime = DateTime.now().add(const Duration(minutes: 5));

    try {
      print('🔄 Resending code to $email');

      await FirebaseFirestore.instance
          .collection('emailVerificationCodes')
          .doc(email)
          .set({
        'email': email,
        'code': code,
        'expiresAt': Timestamp.fromMillisecondsSinceEpoch(
            expirationTime.millisecondsSinceEpoch),
        'sentAt': FieldValue.serverTimestamp(),
      });

      print('✅ New code sent: $code');

      if (mounted) {
        _startResendTimer();
        _showSnackbar('A new code has been sent to ${widget.email}');
      }
    } catch (e) {
      print('❌ Resend error: $e');
      _showSnackbar('Failed to resend code. Please try again.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 🎯 COMPLETELY FIXED VERIFICATION AND LOGIN LOGIC
  Future<void> _verifyCodeAndLogin() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);
    final enteredCode = _codeController.text.trim();
    final email = widget.email;

    try {
      print('🔍 Verifying code for: $email');
      print('📝 Entered code: $enteredCode');

      // 1. Fetch the code from Firestore
      final codeDoc = await FirebaseFirestore.instance
          .collection('emailVerificationCodes')
          .doc(email)
          .get();

      if (!codeDoc.exists) {
        print('❌ No verification code found for this email');
        _showSnackbar('Error: No pending verification for this email.',
            isError: true);
        setState(() => _isLoading = false);
        return;
      }

      final data = codeDoc.data();
      if (data == null) {
        _showSnackbar('Error: Invalid verification data.', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      final storedCode = data['code'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();

      print('✅ Found stored code: $storedCode');
      print('⏰ Expires at: $expiresAt');

      // 2. Check for expiration
      if (expiresAt.isBefore(DateTime.now())) {
        print('❌ Code has expired');
        _showSnackbar('Verification code has expired. Please resend the code.',
            isError: true);
        setState(() => _isLoading = false);
        return;
      }

      // 3. Check for code match
      if (enteredCode != storedCode) {
        print('❌ Code mismatch: entered=$enteredCode, stored=$storedCode');
        _showSnackbar('Invalid verification code.', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      print('✅ Code verified successfully!');

      // 🎯 FIX: Use a consistent dummy password
      const String dummyPassword = 'OTP_AUTH_PASSWORD_2024';

      // 4. Check if user exists in Firestore
      final userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      bool userExistsInFirestore = userQuerySnapshot.docs.isNotEmpty;
      UserCredential? userCredential;

      if (userExistsInFirestore) {
        // 🎯 EXISTING USER - Try to sign in
        print('👤 Existing user detected, attempting sign in...');

        try {
          userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
            email: email,
            password: dummyPassword,
          );

          print('✅ Existing user signed in successfully: ${userCredential.user!.uid}');

        } on FirebaseAuthException catch (e) {
          print('⚠️ Sign-in failed with error: ${e.code}');

          // If sign-in fails, it means the Firebase Auth account doesn't exist
          // even though Firestore has the user. Create the Auth account.
          if (e.code == 'user-not-found' ||
              e.code == 'wrong-password' ||
              e.code == 'invalid-credential') {

            print('🔄 Creating missing Firebase Auth account...');

            try {
              userCredential = await FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                email: email,
                password: dummyPassword,
              );

              print('✅ Auth account recreated: ${userCredential.user!.uid}');

              // Update Firestore with new UID if different
              final oldDoc = userQuerySnapshot.docs.first;
              final oldUid = oldDoc.id;

              if (userCredential.user!.uid != oldUid) {
                final oldData = oldDoc.data();

                // Create new document with correct UID
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userCredential.user!.uid)
                    .set({
                  ...oldData,
                  'uid': userCredential.user!.uid,
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                // Delete old document
                await oldDoc.reference.delete();

                print('✅ User document migrated to new UID');
              }

            } catch (createError) {
              print('❌ Failed to create auth account: $createError');
              throw createError;
            }
          } else {
            // Unknown auth error
            throw e;
          }
        }

      } else {
        // 🎯 NEW USER - Create account
        print('🆕 New user, creating account...');

        try {
          userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
            email: email,
            password: dummyPassword,
          );

          print('✅ New user created: ${userCredential.user!.uid}');

          // Create user profile in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'isDentist': false,
            'authMethod': 'otp',
            'uid': userCredential.user!.uid,
          });

          print('✅ User profile created in Firestore');

        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            // Auth account exists but not in Firestore - sign in instead
            print('⚠️ Auth account exists, signing in instead...');

            userCredential = await FirebaseAuth.instance
                .signInWithEmailAndPassword(
              email: email,
              password: dummyPassword,
            );

            // Create the missing Firestore document
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
              'email': email,
              'createdAt': FieldValue.serverTimestamp(),
              'isDentist': false,
              'authMethod': 'otp',
              'uid': userCredential.user!.uid,
            });

            print('✅ Created missing Firestore document');
          } else {
            throw e;
          }
        }
      }

      // 5. Clean up: Delete the verification code
      await FirebaseFirestore.instance
          .collection('emailVerificationCodes')
          .doc(email)
          .delete();

      print('🧹 Verification code deleted');

      // 6. Navigate to home screen
      if (mounted) {
        final isNewUser = !userExistsInFirestore;
        _showSnackbar(
            isNewUser ? '🎉 Registration successful!' : '✅ Login successful!');

        print('🏠 Navigating to /userHome');

        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/userHome',
                (Route<dynamic> route) => false,
          );
        }
      }

    } on FirebaseAuthException catch (e) {
      print('═══════════════════════════════════');
      print('❌ Firebase Auth Error: ${e.code}');
      print('❌ Message: ${e.message}');
      print('═══════════════════════════════════');

      String errorMessage = 'Authentication Error: ';
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered. Please try signing in.';
          break;
        case 'weak-password':
          errorMessage = 'Internal error. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          break;
        case 'user-not-found':
          errorMessage = 'User not found. Please try again.';
          break;
        case 'wrong-password':
          errorMessage = 'Authentication error. Please try again.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection.';
          break;
        default:
          errorMessage += e.message ?? 'Unknown error occurred';
      }

      _showSnackbar(errorMessage, isError: true);

    } on FirebaseException catch (e) {
      print('═══════════════════════════════════');
      print('❌ Firebase Error: ${e.code}');
      print('❌ Message: ${e.message}');
      print('═══════════════════════════════════');

      _showSnackbar('Database error: ${e.message}', isError: true);

    } catch (e, stackTrace) {
      print('═══════════════════════════════════');
      print('❌ Unexpected Error: $e');
      print('❌ Type: ${e.runtimeType}');
      print('❌ Stack Trace: $stackTrace');
      print('═══════════════════════════════════');

      _showSnackbar('An unexpected error occurred. Please try again.',
          isError: true);

    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.security_update_good_outlined,
                size: 80,
                color: Colors.cyanAccent,
              ),
              const SizedBox(height: 30),
              const Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'A 6-digit code has been sent to\n${widget.email}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              if (widget.isLinkSent)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'The code is valid for 5 minutes.',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 40),

              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    letterSpacing: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '• • • • • •',
                    hintStyle: TextStyle(
                      color: Colors.white38,
                      fontSize: 32,
                      letterSpacing: 10,
                    ),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: Colors.cyanAccent, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.length != 6 ||
                        int.tryParse(value) == null) {
                      return 'Please enter the 6-digit code';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 30),

              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _verifyCodeAndLogin,
                  icon: _isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.login),
                  label: _isLoading
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('VERIFYING...'),
                    ],
                  )
                      : const Text('VERIFY & LOGIN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Resend Button
              TextButton(
                onPressed: _resendTimerSeconds == 0 && !_isLoading
                    ? _resendCode
                    : null,
                child: Text(
                  _resendTimerSeconds > 0
                      ? 'Resend Code in $_resendTimerSeconds seconds'
                      : 'Resend Code',
                  style: TextStyle(
                    color: _resendTimerSeconds == 0 && !_isLoading
                        ? Colors.cyanAccent
                        : Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Go Back Button
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Go Back to Email Input',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}