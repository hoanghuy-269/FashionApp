import 'package:flutter/material.dart';

class ValidatedTextFieldFromRequest extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool hasError;
  final String? errorMessage;
  final int? maxLength;
  final Function(String)? onChanged;

  const ValidatedTextFieldFromRequest({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.keyboardType,
    this.hasError = false,
    this.errorMessage,
    this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          maxLength: maxLength,
          decoration: InputDecoration(
            counterText: "", // ẩn bộ đếm ký tự
            prefixIcon: Icon(icon, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.blueAccent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.grey,
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: hint,
            errorText: hasError ? errorMessage : null,
          ),
        ),
        if (hasError && errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
