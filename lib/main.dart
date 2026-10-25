import 'package:flutter/material.dart';

import 'core/app_info.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GasBillApp());
}

class GasBillApp extends StatelessWidget {
  const GasBillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
