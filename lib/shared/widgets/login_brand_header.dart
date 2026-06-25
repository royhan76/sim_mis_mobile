import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginBrandHeader extends StatelessWidget {
  const LoginBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 126,
          height: 126,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F8B8D).withValues(alpha: 0.10),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Selamat Datang',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF17304D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Masuk ke Portal Wali Santri',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF8796AC),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'PP MIS Sarang',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F8B8D),
          ),
        ),
      ],
    );
  }
}
