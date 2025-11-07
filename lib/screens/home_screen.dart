import 'package:family_planner/screens/section_screen.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../presentation/screens/family_assistant_screen.dart';
import '../presentation/screens/tasks/tasks_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import 'family_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TasksScreen(),
    const FamilyScreen(),
    const SectionScreen(),
    const FamilyAssistantScreen(), // Новый экран
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.familyId != null) {
        // Можно загружать данные
      }
    });
  }

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

  void _onNavItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final taskProvider = Provider.of<TaskProvider>(context, listen: false);
          if (auth.familyId != null) {
            taskProvider.loadTasks(auth.familyId!);
            taskProvider.loadPurchases(auth.familyId!);
            taskProvider.loadWishes(auth.familyId!);
          }
        });

        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _screens,
          ),
          bottomNavigationBar: SafeArea(
            child: _buildBottomNavBar(),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFFFB2B2),
            Color(0xFFFFBF93),
            Color(0xFFFFE6A8),
            Color(0xFFFFBF93),
            Color(0xFFFFB2B2),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: LineAwesomeIcons.home_solid,
              isSelected: _selectedIndex == 0,
              onTap: () => _onNavItemTapped(0),
            ),
            _NavItem(
              icon: LineAwesomeIcons.user_friends_solid,
              isSelected: _selectedIndex == 1,
              onTap: () => _onNavItemTapped(1),
            ),
            _NavItem(
              icon: LineAwesomeIcons.graduation_cap_solid,
              isSelected: _selectedIndex == 2,
              onTap: () => _onNavItemTapped(2),
            ),
            _NavItem(
              icon: LineAwesomeIcons.robot_solid, // Иконка для ассистента
              isSelected: _selectedIndex == 3,
              onTap: () => _onNavItemTapped(3),
            ),
            _NavItem(
              icon: LineAwesomeIcons.user,
              isSelected: _selectedIndex == 4,
              onTap: () => _onNavItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 28,
          color: Colors.black87,
        ),
      ),
    );
  }
}