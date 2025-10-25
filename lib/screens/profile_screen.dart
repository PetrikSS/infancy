import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'welcome_screen.dart';
import 'create_family_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userName ?? 'Пользователь';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Аватар как на экране семьи
              Container(
                width: 120,
                height: 120,
                decoration: _getAvatarDecoration(userName),
                child: Center(
                  child: Text(
                    userName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              if (authProvider.familyId != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE4A3), Color(0xFFFFC0CB)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '👨‍👩‍👧‍👦 В семье',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Не в семье',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
              const SizedBox(height: 40),
              _ProfileOption(
                icon: Icons.edit,
                text: 'Изменить',
                onTap: () {
                  _showEditNameDialog(context, authProvider);
                },
              ),
              const SizedBox(height: 16),
              _ProfileOption(
                icon: Icons.logout,
                text: 'Выйти',
                onTap: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Та же функция для цвета аватара, что и в FamilyScreen
// Замените функцию _getAvatarColor на эту версию с градиентами
  BoxDecoration _getAvatarDecoration(String name) {
    final gradients = [
      // Градиент 1: Синий → Фиолетовый
      const LinearGradient(
        colors: [Color(0xFF2196F3), Color(0xFF9C27B0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      // Градиент 2: Оранжевый → Розовый
      const LinearGradient(
        colors: [Color(0xFFFF9800), Color(0xFFFF4081)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      // Градиент 3: Зеленый → Бирюзовый
      const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF00BCD4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      // Градиент 4: Фиолетовый → Розовый
      const LinearGradient(
        colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      // Градиент 5: Красный → Оранжевый
      const LinearGradient(
        colors: [Color(0xFFF44336), Color(0xFFFF9800)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      // Градиент 6: Бирюзовый → Синий
      const LinearGradient(
        colors: [Color(0xFF00BCD4), Color(0xFF2196F3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      // Градиент 7: Розовый → Персиковый
      const LinearGradient(
        colors: [Color(0xFFE91E63), Color(0xFFFFC107)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      // Градиент 8: Зеленый → Лаймовый
      const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFFCDDC39)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];

    final index = name.hashCode % gradients.length;
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: gradients[index],
    );
  }

  void _showEditNameDialog(BuildContext context, AuthProvider authProvider) {
    final textController = TextEditingController(text: authProvider.userName);
    String selectedRole = authProvider.userType ?? 'child';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Редактировать профиль',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.left,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Поле для имени
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextField(
                  controller: textController,
                  cursorColor: const Color(0xFFFD9791),
                  decoration: const InputDecoration(
                    hintText: 'Введите ваше имя',
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Выбор роли
              const Text(
                'Роль в семье:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 12),

              // Радио-кнопка для ребенка
              GestureDetector(
                onTap: () => setState(() => selectedRole = 'child'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedRole == 'child' ? const Color(0xFFFFC0CB) : Colors.black26,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedRole == 'child' ? const Color(0xFFFFC0CB) : Colors.black26,
                            width: 2,
                          ),
                          color: selectedRole == 'child' ? const Color(0xFFFFC0CB) : Colors.transparent,
                        ),
                        child: selectedRole == 'child'
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Ребенок',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Радио-кнопка для родителя
              GestureDetector(
                onTap: () => setState(() => selectedRole = 'parent'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedRole == 'parent' ? const Color(0xFFFFC0CB) : Colors.black26,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedRole == 'parent' ? const Color(0xFFFFC0CB) : Colors.black26,
                            width: 2,
                          ),
                          color: selectedRole == 'parent' ? const Color(0xFFFFC0CB) : Colors.transparent,
                        ),
                        child: selectedRole == 'parent'
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Родитель',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Отмена',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFC0CB), Color(0xFFFFD4A3)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: TextButton(
                        onPressed: () async {
                          final newName = textController.text.trim();
                          if (newName.isNotEmpty) {
                            // Обновляем и имя, и роль
                            final nameError = await authProvider.updateUserName(newName);
                            final roleError = await authProvider.updateUserRole(selectedRole);

                            if (nameError == null && roleError == null && context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Профиль успешно обновлен'),
                                  backgroundColor: Colors.black87,
                                ),
                              );
                            } else if (context.mounted) {
                              final errorMessage = nameError ?? roleError;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Ошибка: $errorMessage'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Введите имя'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Сохранить',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}