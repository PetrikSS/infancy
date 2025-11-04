import 'package:family_planner/screens/tasks_screen.dart';
import 'package:flutter/material.dart';
import '../presentation/screens/auth/UnifiedAuthScreen.dart';
import 'home_screen.dart';
import '../DeleteLater/login_screen.dart';
import '../DeleteLater/register_screen.dart';
import '../DeleteLater/register_screen_.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: Container(

/*        decoration: const BoxDecoration(
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
        ),*/
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
                SvgPicture.asset("assets/images/enter-your-password.svg"),
                const Spacer(),
                _GradientButton(
                  text: 'Войти',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const UnifiedAuthScreen()),
                    );

// Кнопку "Зарегистрироваться" можно удалить или тоже вести на UnifiedAuthScreen
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (_) => const LoginScreen()),
                    // ); //HomeScreen
                  },
                  isPrimary: true,
                ),
                const SizedBox(height: 16),
                _GradientButton(
                  text: 'Зарегистрироваться',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const UnifiedAuthScreen() /*RegisterScreen()*/),
                    );
                  },
                  isPrimary: false,
                ),
                const SizedBox(height: 12),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    child: Text(
                      "Продолжить без аккаунта",
                      style: TextStyle(color: Colors.black26),
                    )),
                const SizedBox(height: 30),
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
  final bool isLoading;

  const _GradientButton({
    required this.text,
    required this.onPressed,
    required this.isPrimary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(

        gradient: const LinearGradient(
          colors: [Color(0xFFFFC0CB), Color(0xFFFFD4A3)],
        ),

      /*  color: isPrimary
            ? Colors.white
            : Colors.transparent, // Белый фон для кнопки "Войти"*/
        borderRadius: BorderRadius.circular(28),
  /*      border: isPrimary
            ? null
            : Border.all(
                color: Colors.white,
                width: 2.0, // Жирная белая обводка для "Зарегистрироваться"
              ),*/
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : Text(
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
