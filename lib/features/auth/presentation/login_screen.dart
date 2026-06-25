import 'package:flutter/material.dart';

import '../../../app/app_navigator.dart';
import '../data/models/santri_session.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/auth_api_service.dart';
import '../../../app/session_home.dart';
import '../../../shared/widgets/labeled_field.dart';
import '../../../shared/widgets/login_brand_header.dart';
import '../../../shared/widgets/primary_gradient_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'NIK dan password wajib diisi.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final SantriSession session = await _authRepository.login(
        username: username,
        password: password,
      );

      if (!mounted) {
        return;
      }

      AppNavigator.key.currentState?.pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => buildSessionHome(
            session: session,
            onLogout: () => _authRepository.logout(session),
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat login.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF3F7FC), Color(0xFFF8FBFD)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const LoginBrandHeader(),
                    const SizedBox(height: 34),
                    LabeledField(
                      controller: _usernameController,
                      hintText: 'NIK Santri',
                      icon: Icons.badge_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    LabeledField(
                      controller: _passwordController,
                      hintText: 'Kata Sandi',
                      icon: Icons.lock_rounded,
                      obscureText: _obscurePassword,
                      suffixIcon: _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      onSuffixPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Lupa Kata Sandi?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F8B8D),
                          ),
                        ),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    PrimaryGradientButton(
                      label: 'MASUK SEKARANG',
                      icon: Icons.arrow_forward_rounded,
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: const [
                        Text(
                          'Belum punya akun? ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8B98AB),
                          ),
                        ),
                        Text(
                          'Daftar Wali Baru',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F8B8D),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

