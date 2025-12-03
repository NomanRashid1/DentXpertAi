import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditDoctorProfileScreen extends StatefulWidget {
  final String doctorEmail;
  const EditDoctorProfileScreen({super.key, required this.doctorEmail});

  @override
  State<EditDoctorProfileScreen> createState() =>
      _EditDoctorProfileScreenState();
}

class _EditDoctorProfileScreenState extends State<EditDoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = true;
  DocumentReference? _docRef;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final query =
        await FirebaseFirestore.instance
            .collection('dentists')
            .where('email', isEqualTo: widget.doctorEmail)
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      _docRef = query.docs.first.reference;
      data.forEach((key, value) {
        _controllers[key] = TextEditingController(text: value.toString());
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _docRef == null) return;

    final updatedData = <String, dynamic>{};
    _controllers.forEach((key, controller) {
      updatedData[key] = controller.text;
    });

    await _docRef!.update(updatedData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Edit Doctor Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF001F3F), Color(0xFF004080)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.cyanAccent,
                      ),
                    )
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                const Text(
                                  'Update Your Details',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ..._controllers.entries.map((entry) {
                                  final key = entry.key;
                                  final controller = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: TextFormField(
                                      controller: controller,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      obscureText: key == 'password',
                                      keyboardType:
                                          (key == 'charges' || key == 'phone')
                                              ? TextInputType.number
                                              : TextInputType.text,
                                      decoration: InputDecoration(
                                        labelText:
                                            key[0].toUpperCase() +
                                            key.substring(1),
                                        labelStyle: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white10,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        prefixIcon: Icon(
                                          key == 'email'
                                              ? Icons.email
                                              : key == 'phone'
                                              ? Icons.phone
                                              : key == 'password'
                                              ? Icons.lock_outline
                                              : Icons.person,
                                          color: Colors.cyanAccent,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter $key';
                                        }
                                        if (key == 'email' &&
                                            !value.contains('@')) {
                                          return 'Enter valid email';
                                        }
                                        if (key == 'password' &&
                                            value.length < 6) {
                                          return 'Password too short';
                                        }
                                        return null;
                                      },
                                    ),
                                  );
                                }),
                                const SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _saveProfile,
                                    icon: const Icon(Icons.save),
                                    label: const Text('Save Changes'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyanAccent,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
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
        ],
      ),
    );
  }
}
