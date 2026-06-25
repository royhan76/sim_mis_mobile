import 'package:flutter/material.dart';

import 'app_bootstrap.dart';
import 'app_navigator.dart';
import 'app_theme.dart';

class SimMisApp extends StatelessWidget {
  const SimMisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIM MIS Sarang',
      navigatorKey: AppNavigator.key,
      theme: AppTheme.light(),
      home: const AppBootstrap(),
    );
  }
}
