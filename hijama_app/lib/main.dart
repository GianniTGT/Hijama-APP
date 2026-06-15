import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/localization_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'utils/app_theme.dart';
import 'utils/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  // Localization (loads saved language preference + JSON strings)
  localization = LocalizationService();
  await localization.init();

  // Notifications
  await NotificationService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(localization),
      child: const HijamaApp(),
    ),
  );
}

class HijamaApp extends StatelessWidget {
  const HijamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return MaterialApp(
      title: 'Hijama Guide',
      debugShowCheckedModeBanner: false,

      // RTL support for Arabic
      builder: (context, child) {
        return Directionality(
          textDirection: state.isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      home: state.isFirstLaunch
          ? const OnboardingScreen()
          : const HomeScreen(),
    );
  }
}
