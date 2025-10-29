import 'package:flutter/material.dart';

class ValidatedTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final bool error;
  final String errorMessage;
  final bool Function(String) validator;
  final VoidCallback onChanged;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? toggleObscure;

  const ValidatedTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    required this.error,
    required this.errorMessage,
    required this.validator,
    required this.onChanged,
    this.isPassword = false,
    this.obscureText = false,
    this.toggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: 'Nhập $label',
            prefixIcon: Icon(icon),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: toggleObscure,
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error ? Colors.red : Colors.deepPurple,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error ? Colors.red : Colors.grey,
                width: 1.5,
              ),
            ),
            errorText: error ? errorMessage : null,
          ),
        ),
      ],
    );
  }
}
