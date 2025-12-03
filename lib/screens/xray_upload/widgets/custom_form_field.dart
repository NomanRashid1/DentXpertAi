import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isNumber;
  final bool required;
  final bool isEmail;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isNumber = false,
    this.required = false,
    this.isEmail = false,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType:
            isNumber
                ? TextInputType.number
                : isEmail
                ? TextInputType.emailAddress
                : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon:
              prefixIcon != null
                  ? Icon(prefixIcon, color: Colors.white70)
                  : isEmail
                  ? const Icon(Icons.email_outlined, color: Colors.white70)
                  : null,
        ),
        validator:
            validator ??
            (value) {
              if (required && (value == null || value.isEmpty)) {
                return 'Required field';
              }
              if (isEmail && value != null && value.isNotEmpty) {
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Enter a valid email address';
                }
              }
              return null;
            },
      ),
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool required;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: const Color(0xFF033053),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        style: const TextStyle(color: Colors.white),
        items:
            options
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        validator:
            required
                ? (value) => value == null || value.isEmpty ? 'Required' : null
                : null,
      ),
    );
  }
}
