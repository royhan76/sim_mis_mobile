import 'package:flutter/material.dart';

import '../features/alumni/presentation/alumni_dashboard_screen.dart';
import '../features/auth/data/models/santri_session.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';

Widget buildSessionHome({
  required SantriSession session,
  required Future<void> Function() onLogout,
}) {
  final role = session.user.role.trim().toLowerCase();

  if (role == 'alumni') {
    return AlumniDashboardScreen(
      session: session,
      onLogout: onLogout,
    );
  }

  return DashboardScreen(
    session: session,
    onLogout: onLogout,
  );
}
