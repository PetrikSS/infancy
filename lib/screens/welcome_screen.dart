import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFFFEDC9),
              Color(0xFFFFD8BE),
              Color(0xFFFFB2B2),
              Color(0xFFFFBF93),
              Color(0xFFFFE6A8),
              // Color(0xFFFFF4E6),
              // Color(0xFFFFE4E1),
              // Color(0xFFFFC0CB),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text(
                  'Добро пожаловать!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 80),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(1),
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.8),
                        Colors.white.withOpacity(0.7),
                        Colors.white.withOpacity(0.6),
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(0.4),
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.01),
                        Colors.white.withOpacity(0.001),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                _GradientButton(
                  text: 'Войти',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ); //HomeScreen
                  },
                  isPrimary: true,
                ),
                const SizedBox(height: 16),
                _GradientButton(
                  text: 'Зарегистрироваться',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  isPrimary: false,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _GradientButton({
    required this.text,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: isPrimary ? Colors.white : Colors.transparent, // Белый фон для кнопки "Войти"
        borderRadius: BorderRadius.circular(28),
        border: isPrimary
            ? null
            : Border.all(
          color: Colors.white,
          width: 2.0, // Жирная белая обводка для "Зарегистрироваться"
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black, // Черный текст для обеих кнопок
              ),
            ),
          ),
        ),
      ),
    );
  }
}