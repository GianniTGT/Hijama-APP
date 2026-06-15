import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../utils/app_state.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A4A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo / Icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D7A4A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text('🌙', style: TextStyle(fontSize: 52)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Hijama Guide',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF0D080),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'حجامة • Nach der Sunnah',
                style: TextStyle(fontSize: 14, color: Color(0xFF9FE1CB)),
              ),
              const Spacer(),
              // Language selection header
              const Text(
                'Sprache wählen  /  اختر اللغة',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9FE1CB),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              // Language buttons
              ...LocalizationService.supportedLanguages.map(
                (lang) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _LanguageButton(lang: lang),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({required this.lang});
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isSelected = state.currentLanguage == lang.code;

    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: OutlinedButton(
          onPressed: () async {
            await context.read<AppState>().setLanguage(lang.code);
            await Future.delayed(const Duration(milliseconds: 300));
            await context.read<AppState>().completeOnboarding();
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: isSelected
                ? const Color(0xFF1A4A2E)
                : const Color(0xFFF0D080),
            backgroundColor: isSelected
                ? const Color(0xFFF0D080)
                : Colors.transparent,
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFFF0D080)
                  : const Color(0xFF2D7A4A),
              width: isSelected ? 2 : 1,
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                lang.nativeLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                lang.label,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
