import 'package:flutter/material.dart';

class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixPressed,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixPressed;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF17304D),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF94A3B8),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
        suffixIcon: suffixIcon == null
            ? null
            : IconButton(
                icon: Icon(suffixIcon, color: const Color(0xFF94A3B8)),
                onPressed: onSuffixPressed,
              ),
      ),
    );
  }
}
