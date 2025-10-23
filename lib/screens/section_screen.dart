import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class SectionScreen extends StatelessWidget {
  const SectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Декоративный элемент с градиентом
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC0CB), Color(0xFFFFD4A3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                LineAwesomeIcons.rocket_solid,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            // Текст
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Скоро появится!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Подзаголовок
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Мы работаем над этим разделом,\nи скоро он будет доступен!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF888888),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Декоративные элементы
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(),
                const SizedBox(width: 8),
                _buildDot(),
                const SizedBox(width: 8),
                _buildDot(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFFFFC0CB),
        shape: BoxShape.circle,
      ),
    );
  }
}