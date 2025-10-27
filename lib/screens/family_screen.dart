import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/family_provider.dart';
import '../models/family_member.dart';
import 'create_family_screen.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({Key? key}) : super(key: key);

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Загружаем данные только один раз при первой инициализации
    if (!_isInitialized) {
      _loadFamilyData();
      _isInitialized = true;
    }
  }

  Future<void> _loadFamilyData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final familyProvider = Provider.of<FamilyProvider>(context, listen: false);

    if (authProvider.familyId != null) {
      await familyProvider.loadFamilyMembers(authProvider.familyId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Моя семья',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Consumer2<AuthProvider, FamilyProvider>(
        builder: (context, authProvider, familyProvider, child) {
          // Если нет семьи, показываем экран создания/присоединения
          if (authProvider.familyId == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.family_restroom,
                    size: 80,
                    color: Colors.black26,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Вы еще не в семье',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Создайте новую семью или присоединитесь к существующей',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: _buildAddFamilyButton(context),
                  ),
                ],
              ),
            );
          }

          if (familyProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final familyMembers = familyProvider.familyMembers;

          return Column(
            children: [
              // Статистика выполненных задач
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEDCF8C), width: 1),
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.local_fire_department_outlined,
                      color: Color(0xFFFF8989),
                      size: 36,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${familyProvider.completedTasksCount} задач выполнено вместе\nза месяц!',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),

              // Список участников семьи
              Expanded(
                child: familyMembers.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.black26,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Нет участников семьи',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: _loadFamilyData,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: familyMembers.length,
                    itemBuilder: (context, index) {
                      final member = familyMembers[index];
                      return _FamilyMemberCard(member: member);
                    },
                  ),
                ),
              ),

              // Кнопка добавления участника
              Container(
                padding: const EdgeInsets.all(16),
                child: _buildAddFamilyButton(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddFamilyButton(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFC0CB), // Розовый
            Color(0xFFFFD4A3), // Персиковый
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateFamilyScreen(),
              ),
            );

            // Если вернулись с результатом, перезагружаем данные
            if (result == true && mounted) {
              setState(() {
                _isInitialized = false;
              });
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline,
                color: Colors.black87,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                Provider.of<AuthProvider>(context).familyId == null
                    ? 'Создать/Присоединиться'
                    : 'Добавить участника',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;

  const _FamilyMemberCard({Key? key, required this.member}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Аватар пользователя
          Container(
            width: 50,
            height: 50,
            decoration: _getAvatarDecoration(member.name),
            child: Center(
              child: Text(
                member.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Информация о пользователе
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.role == FamilyRole.parent ? 'Родитель' : 'Ребенок',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                // Прогресс выполнения задач на сегодня
                Row(
                  children: [
                    Text(
                      'Сегодня ${member.todayCompletedTasks}/${member.todayTotalTasks} задач',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF272727),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Иконка роли
          Icon(
            member.role == FamilyRole.parent
                ? Icons.family_restroom_rounded
                : Icons.child_care_rounded,
            color: member.role == FamilyRole.parent
                ? const Color(0xFF2196F3)
                : const Color(0xFFFF9800),
            size: 24,
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  BoxDecoration _getAvatarDecoration(String name) {
    final gradients = [
      const LinearGradient(
        colors: [Color(0xFF2196F3), Color(0xFF9C27B0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFFF9800), Color(0xFFFF4081)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF00BCD4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFF44336), Color(0xFFFF9800)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF00BCD4), Color(0xFF2196F3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFE91E63), Color(0xFFFFC107)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
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
}