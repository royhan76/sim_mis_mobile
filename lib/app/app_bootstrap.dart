import 'package:flutter/material.dart';

import '../features/auth/data/models/santri_session.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import '../features/auth/presentation/login_screen.dart';
import 'session_home.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  final AuthRepository _authRepository = AuthRepository();
  late final Future<SantriSession?> _sessionFuture = _loadSession();

  Future<SantriSession?> _loadSession() async {
    return _authRepository.restoreSession();
  }

  Future<void> _clearSession(SantriSession session) async {
    await _authRepository.logout(session);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SantriSession?>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final session = snapshot.data;
        if (session != null) {
          return buildSessionHome(
            session: session,
            onLogout: () => _clearSession(session),
          );
        }

        return const LoginScreen();
      },
    );
  }
}
