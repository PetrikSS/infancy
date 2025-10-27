import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/family_provider.dart';

class CreateFamilyScreen extends StatefulWidget {
  const CreateFamilyScreen({super.key});

  @override
  State<CreateFamilyScreen> createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends State<CreateFamilyScreen> {
  final _partnerIdController = TextEditingController();
  bool _isLoading = false;
  bool _isCreatingNew = true;

  @override
  void dispose() {
    _partnerIdController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateFamily() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final familyProvider = Provider.of<FamilyProvider>(context, listen: false);

      final error = await authProvider.createNewFamily();

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (error != null) {
        _showError(error);
      } else {
        await familyProvider.loadFamilyMembers(authProvider.familyId!);
        _showSuccess('Семья успешно создана!');
        if (mounted) {
          Navigator.pop(context, true); // ← Возвращаем true
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Ошибка: $e');
    }
  }

  Future<void> _handleJoinFamily() async {
    if (_partnerIdController.text.isEmpty) {
      _showError('Введите ID партнера');
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final familyProvider = Provider.of<FamilyProvider>(context, listen: false);

      final error = await authProvider.joinFamily(_partnerIdController.text.trim());

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (error != null) {
        _showError(error);
      } else {
        await familyProvider.loadFamilyMembers(authProvider.familyId!);
        _showSuccess('Вы успешно присоединились к семье!');
        if (mounted) {
          Navigator.pop(context, true); // ← Возвращаем true
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Ошибка: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Назад',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Создать или войти в семью',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Переключатель режимов
            Row(
              children: [
                Expanded(
                  child: _ModeButton(
                    text: 'Создать новую',
                    isSelected: _isCreatingNew,
                    onTap: () => setState(() => _isCreatingNew = true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ModeButton(
                    text: 'Присоединиться',
                    isSelected: !_isCreatingNew,
                    onTap: () => setState(() => _isCreatingNew = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (_isCreatingNew) ...[
              // Режим создания новой семьи
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Создайте новую семью',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'После создания семьи, поделитесь своим ID с партнером, чтобы он мог присоединиться к вашей семье.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Ваш ID:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              userId,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: userId));
                              _showSuccess('ID скопирован в буфер обмена');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _GradientButton(
                text: 'Создать семью',
                onPressed: _isLoading ? null : _handleCreateFamily,
                isLoading: _isLoading,
              ),
            ] else ...[
              // Режим присоединения к существующей семье
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Присоединиться к семье',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Введите ID пользователя, который уже создал семью. Попросите его поделиться ID из раздела "Создать новую".',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _CustomTextField(
                      controller: _partnerIdController,
                      hint: 'ID партнера',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _GradientButton(
                text: 'Присоединиться к семье',
                onPressed: _isLoading ? null : _handleJoinFamily,
                isLoading: _isLoading,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFFFFE4A3), Color(0xFFFFC0CB)],
          )
              : null,
          border: isSelected ? null : Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(28),
          color: isSelected ? null : Colors.white,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.black87 : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _CustomTextField({
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(28),
      ),
      child: TextField(
        cursorColor: Color(0xFFFD9791),
        controller: controller,
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
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}