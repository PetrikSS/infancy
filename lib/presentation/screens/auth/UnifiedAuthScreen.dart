import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../screens/home_screen.dart';

class UnifiedAuthScreen extends StatefulWidget {
  const UnifiedAuthScreen({super.key});

  @override
  State<UnifiedAuthScreen> createState() => _UnifiedAuthScreenState();
}

class _UnifiedAuthScreenState extends State<UnifiedAuthScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  void _switchPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleLogin() async {
    if (_loginEmailController.text.isEmpty || _loginPasswordController.text.isEmpty) {
      _showError('Пожалуйста, заполните все поля');
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.signIn(
      _loginEmailController.text.trim(),
      _loginPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (error != null) {
      _showError(error);
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  Future<void> _handleRegister() async {
    if (_registerEmailController.text.isEmpty ||
        _registerPasswordController.text.isEmpty ||
        _registerConfirmPasswordController.text.isEmpty) {
      _showError('Пожалуйста, заполните все поля');
      return;
    }

    if (_registerPasswordController.text != _registerConfirmPasswordController.text) {
      _showError('Пароли не совпадают');
      return;
    }

    if (_registerPasswordController.text.length < 6) {
      _showError('Пароль должен быть не менее 6 символов');
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.signUp(
      email: _registerEmailController.text.trim(),
      password: _registerPasswordController.text,
      name: '',
      birthDate: '',
      userType: 'parent',
    );

    setState(() => _isLoading = false);

    if (error != null) {
      _showError(error);
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFEDC9),
              Color(0xFFFFD8BE),
              Color(0xFFFFB2B2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Переключатель вкладок
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        text: 'Вход',
                        isSelected: _currentPage == 0,
                        onTap: () => _switchPage(0),
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        text: 'Регистрация',
                        isSelected: _currentPage == 1,
                        onTap: () => _switchPage(1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Контент страниц
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildLoginPage(),
                    _buildRegisterPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Добро пожаловать!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Войдите в свой аккаунт',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _CustomTextField(
              controller: _loginEmailController,
              hint: 'Почта',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _CustomTextField(
              controller: _loginPasswordController,
              hint: 'Пароль',
              obscureText: true,
            ),
            const SizedBox(height: 40),
            _GradientButton(
              text: 'Войти',
              onPressed: _isLoading ? null : _handleLogin,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Создать аккаунт',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Присоединяйтесь к нам!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _CustomTextField(
              controller: _registerEmailController,
              hint: 'Почта',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _CustomTextField(
              controller: _registerPasswordController,
              hint: 'Пароль',
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _CustomTextField(
              controller: _registerConfirmPasswordController,
              hint: 'Подтвердите пароль',
              obscureText: true,
            ),
            const SizedBox(height: 40),
            _GradientButton(
              text: 'Зарегистрироваться',
              onPressed: _isLoading ? null : _handleRegister,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black87 : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _CustomTextField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(28),
      ),
      child: TextField(
        controller: controller,
        cursorColor: const Color(0xFFFD9791),
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _GradientButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC0CB), Color(0xFFFFD4A3)],
        ),
        borderRadius: BorderRadius.circular(28),
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
                color: Colors.white,
              ),
            )
                : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}