import 'package:family_planner/screens/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/task_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../screens/create_purchase_screen.dart';
import 'create_task_screen.dart';
import '../../../screens/create_wish_screen.dart';
import '../../../screens/edit_item_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();
  DateTime _displayedMonth = DateTime.now();

  final List<String> _tabNames = ['Задачи', 'Календарь', 'Покупки', 'Желания'];
  bool _isLoading = true; // 👈 Добавляем флаг загрузки
/*  @override
  void initState() {
    super.initState();
    _loadData();
  }*/
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true); // 👈 Перед загрузкой показываем спиннер

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    if (authProvider.familyId != null) {
      await Future.wait([
        taskProvider.loadTasks(authProvider.familyId!),
        taskProvider.loadPurchases(authProvider.familyId!),
        taskProvider.loadWishes(authProvider.familyId!),
      ]);
    }

    if (mounted) setState(() => _isLoading = false); // 👈 После загрузки скрываем
  }
/*  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    if (authProvider.familyId != null) {
      await taskProvider.loadTasks(authProvider.familyId!);
      await taskProvider.loadPurchases(authProvider.familyId!);
      await taskProvider.loadWishes(authProvider.familyId!);
    }
  }*/

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

/*  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _buildTodayTasks(),
                  _buildMonthTasks(),
                  _buildPurchases(),
                  _buildWishes(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _isLoading
            ? const Center( // 👈 Показываем красивый лоадер
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFFFF8989),
                strokeWidth: 4,
              ),
              SizedBox(height: 16),
              Text(
                'Загружаем задачи...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        )
            : Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _buildTodayTasks(),
                  _buildMonthTasks(),
                  _buildPurchases(),
                  _buildWishes(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isLoading ? null : _buildFAB(), // 👈 Пока грузится — скрываем FAB
    );
  }


  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[400], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Задача',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      enabled: false, // Пока не реализуем функциональность
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_tabNames.length, (index) {
          return Expanded(
            child: GestureDetector(
              onTap: () => _onTabTapped(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  gradient: _selectedIndex == index
                      ? const LinearGradient(
                    colors: [Color(0xFFFFEDC9), Color(0xFFFFD8BE)],
                  )
                      : null,
                  color: _selectedIndex == index ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    _tabNames[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _selectedIndex == index
                          ? Colors.black87
                          : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget? _buildFAB() {
    // Показываем FAB только на экранах "Сегодня" и "Месяц"
    if (_selectedIndex > 1) return null;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFBF93), Color(0xFFFF8989)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToCreate(context, 'task'),
          borderRadius: BorderRadius.circular(28),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildTodayTasks() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final todayTasks = taskProvider.tasks;

        return todayTasks.isEmpty
            ? _buildEmptyState('Нет задач на сегодня')
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: todayTasks.length,
          itemBuilder: (context, index) {
            return _NewTaskItem(task: todayTasks[index]);
          },
        );
      },
    );
  }

  Widget _buildMonthTasks() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final monthTasks = taskProvider.getMonthTasks();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCalendar(),
              const SizedBox(height: 16),
              if (monthTasks.isEmpty)
                _buildEmptyState('Нет задач на этот месяц')
              else
                ...monthTasks.map((task) => _NewTaskItem(task: task)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month - 1,
                    );
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(_displayedMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWeekDays(),
          const SizedBox(height: 8),
          _buildDaysGrid(),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    const weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((day) {
        return SizedBox(
          width: 40,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black38,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDaysGrid() {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final startingWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    return Column(
      children: List.generate(6, (weekIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (dayIndex) {
              final dayNumber = weekIndex * 7 + dayIndex - startingWeekday + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox(width: 40, height: 40);
              }

              final date = DateTime(_displayedMonth.year, _displayedMonth.month, dayNumber);
              final isSelected = _selectedDate.year == date.year &&
                  _selectedDate.month == date.month &&
                  _selectedDate.day == date.day;
              final isToday = DateTime.now().year == date.year &&
                  DateTime.now().month == date.month &&
                  DateTime.now().day == date.day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isToday
                        ? const LinearGradient(
                      colors: [Color(0xFF4A4A4A), Color(0xFF2A2A2A)],
                    )
                        : null,
                    color: isSelected && !isToday ? Colors.black12 : null,
                  ),
                  child: Center(
                    child: Text(
                      dayNumber.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isToday ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildPurchases() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final personalPurchases = taskProvider.getPersonalPurchases();
        final familyPurchases = taskProvider.getFamilyPurchases();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PersonalPurchasesCard(
                title: 'Личные покупки',
                purchases: personalPurchases,
                onAdd: () => _navigateToCreate(context, 'purchase'),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Семейные покупки',
                items: familyPurchases,
                onAdd: () => _navigateToCreate(context, 'purchase'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWishes() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionCard(
                title: 'Мои желания',
                items: taskProvider.wishes
                    .where((w) => w.category == 'personal')
                    .toList(),
                onAdd: () => _navigateToCreate(context, 'wish'),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Семейные желания',
                items: taskProvider.wishes
                    .where((w) => w.category == 'family')
                    .toList(),
                onAdd: () => _navigateToCreate(context, 'wish'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _navigateToCreate(BuildContext context, String type) async {
    Widget screen;
    switch (type) {
      case 'task':
        screen = const CreateTaskScreen();
        break;
      case 'purchase':
        screen = const CreatePurchaseScreen();
        break;
      case 'wish':
        screen = const CreateWishScreen();
        break;
      default:
        return;
    }

    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

    // Перезагружаем данные после возврата
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      if (authProvider.familyId != null) {
        await taskProvider.loadTasks(authProvider.familyId!);
        await taskProvider.loadPurchases(authProvider.familyId!);
        await taskProvider.loadWishes(authProvider.familyId!);
      }
    }
  }
}

// Новый виджет для задачи в стиле макета
class _NewTaskItem extends StatelessWidget {
  final dynamic task;

  const _NewTaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        return GestureDetector(
          onTap: () {
            _navigateToEdit(context, task, 'task');
          },
          onLongPress: () {
            taskProvider.deleteTask(task.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"${task.title}" удален'),
                backgroundColor: Colors.red,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Чекбокс
                GestureDetector(
                  onTap: () {
                    taskProvider.toggleTaskCompletion(task.id, !task.completed);
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.completed
                            ? const Color(0xFFFF8989)
                            : const Color(0xFFE0E0E0),
                        width: 2,
                      ),
                      color: task.completed
                          ? const Color(0xFFFF8989)
                          : Colors.transparent,
                    ),
                    child: task.completed
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Текст задачи
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.completed
                              ? Colors.grey[400]
                              : Colors.black87,
                        ),
                      ),
                      if (task.assignedUserIds != null &&
                          task.assignedUserIds!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 14,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Анастасия (Вы)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Остальные виджеты остаются без изменений
class _SectionCard extends StatelessWidget {
  final String title;
  final List items;
  final VoidCallback onAdd;

  const _SectionCard({
    required this.title,
    required this.items,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFC0CB), Color(0xFFFFD4A3)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 20, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            _buildEmptyState()
          else
            _buildItemsList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: const Center(
        child: Text(
          'Нет элементов',
          style: TextStyle(
            color: Colors.black38,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDCF8C)),
      ),
      child: Column(
        children: items.map((item) => _SectionItem(item: item)).toList(),
      ),
    );
  }
}

class _SectionItem extends StatelessWidget {
  final dynamic item;

  const _SectionItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        return GestureDetector(
          onTap: () {
            String type = 'task';
            if (item.type == TaskType.purchase) type = 'purchase';
            if (item.type == TaskType.wish) type = 'wish';
            _navigateToEdit(context, item, type);
          },
          onLongPress: () {
            taskProvider.deleteTask(item.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"${item.title}" удален'),
                backgroundColor: Colors.red,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDCF8C), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      taskProvider.toggleTaskCompletion(item.id, !item.completed);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: item.completed ? Colors.black : Colors.black26,
                          width: 2,
                        ),
                        color: item.completed ? Colors.black : Colors.transparent,
                      ),
                      child: item.completed
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: item.completed ? TextDecoration.lineThrough : null,
                        color: item.completed ? Colors.black54 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PersonalPurchasesCard extends StatelessWidget {
  final String title;
  final List purchases;
  final VoidCallback onAdd;

  const _PersonalPurchasesCard({
    required this.title,
    required this.purchases,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFC0CB), Color(0xFFFFD4A3)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 20, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (purchases.isEmpty)
            _buildEmptyState()
          else
            _buildPurchasesList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: const Center(
        child: Text('Нет покупок', style: TextStyle(color: Colors.black38, fontSize: 14)),
      ),
    );
  }

  Widget _buildPurchasesList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
      child: Column(
        children: [...purchases.map((purchase) => _PurchaseItem(purchase: purchase))],
      ),
    );
  }
}

class _PurchaseItem extends StatelessWidget {
  final dynamic purchase;

  const _PurchaseItem({required this.purchase});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        return GestureDetector(
          onTap: () {
            _navigateToEdit(context, purchase, 'purchase');
          },
          onLongPress: () {
            taskProvider.deleteTask(purchase.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"${purchase.title}" удален'),
                backgroundColor: Colors.red,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFB2B2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      taskProvider.toggleTaskCompletion(purchase.id, !purchase.completed);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFB2B2),
                          width: 2,
                        ),
                        color: purchase.completed ? const Color(0xFFFFB2B2) : Colors.transparent,
                      ),
                      child: purchase.completed
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      purchase.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: purchase.completed ? TextDecoration.lineThrough : null,
                        color: purchase.completed ? Colors.black54 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void _navigateToEdit(BuildContext context, dynamic item, String type) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EditItemScreen(item: item, itemType: type),
    ),
  );
}