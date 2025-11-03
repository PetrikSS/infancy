import 'package:family_planner/screens/section_screen.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import 'family_screen.dart';
import 'tasks_screen.dart';
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
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    if (authProvider.familyId != null) {
      await taskProvider.loadTasks(authProvider.familyId!);
      await taskProvider.loadPurchases(authProvider.familyId!);
      await taskProvider.loadWishes(authProvider.familyId!);
    }
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
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: Container(
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
                icon: LineAwesomeIcons.user,
                isSelected: _selectedIndex == 3,
                onTap: () => _onNavItemTapped(3),
              ),
            ],
          ),
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