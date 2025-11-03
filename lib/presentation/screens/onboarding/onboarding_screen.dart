import 'package:family_planner/main.dart';
import 'package:family_planner/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'login_screen.dart';
import '../../../providers/auth_provider.dart';
import '../../../screens/home_screen.dart';
import '../../../DeleteLater/register_screen_.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Всё под рукой!',
      description: 'Все задачи и расписания вашей семьи в одном месте!',
      imageAsset: 'assets/images/about-us.svg', // Замените на ваши пути к картинкам
      color: const Color(0xFFF5F5F5),
    ),
    OnboardingPage(
      title: 'Ваш прогресс',
      description: 'Назначайте ответственных и отслеживайте прогресс!',
      imageAsset: 'assets/images/change-settings.svg',
      color: const Color(0xFFF5F5F5),
    ),
    OnboardingPage(
      title: 'Занятия для всей семьи',
      description: 'Персональные подборки кружков, секций и мероприятий!',
      imageAsset: 'assets/images/designer-working.svg',
      color: const Color(0xFFF5F5F5),
    ),
    OnboardingPage(
      title: 'Ваши желания',
      description: 'Составляйте вишлист — дети добавят желания, а вы будете знать, что подарить!',
      imageAsset: 'assets/images/free-shipping.svg',
      color: const Color(0xFFF5F5F5),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            if (_currentPage < _pages.length - 1)
              Padding(padding: const EdgeInsets.only(top: 16, right: 24),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _goToAuth,
                    child: const Text(
                      'Пропустить',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                ),
            // Контент
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _OnboardingPageContent(page: _pages[index]);
                },
              ),
            ),

            // Индикаторы и кнопки
            _BottomSection(
              currentPage: _currentPage,
              totalPages: _pages.length,
              onNext: _nextPage,
              onGetStarted: _goToAuth,
            ),
          ],
        ),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      _goToAuth();
    }
  }

  void _goToAuth() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthWrapper()),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String imageAsset;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.color,
  });
}

class _OnboardingPageContent extends StatelessWidget {
  final OnboardingPage page;

  const _OnboardingPageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Expanded(
            flex: 3,
            child: SvgPicture.asset(
              page.imageAsset,
              fit: BoxFit.contain,
            ),
          ),
          // Текст
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSection extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;

  const _BottomSection({
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          // Индикаторы
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == currentPage
                      ? Colors.black
                      : Colors.black.withOpacity(0.3),
                ),
              );
            }),
          ),

          const SizedBox(height: 32),

          // Кнопка Далее/Начать с использованием _GradientButton
          _GradientButton(
            text: currentPage == totalPages - 1 ? 'Начать!' : 'Далее',
            onPressed: currentPage == totalPages - 1 ? onGetStarted : onNext,
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const _GradientButton({
    required this.text,
    required this.onPressed,
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
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return authProvider.currentUser != null
        ? const HomeScreen()
        : const WelcomeScreen();
  }
}