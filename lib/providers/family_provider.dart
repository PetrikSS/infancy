import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/family_member.dart';

class FamilyProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<FamilyMember> _familyMembers = [];
  bool _isLoading = false;
  int _completedTasksCount = 0;

  List<FamilyMember> get familyMembers => _familyMembers;
  bool get isLoading => _isLoading;
  int get completedTasksCount => _completedTasksCount;

  Future<void> loadFamilyMembers(String familyId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Загружаем участников семьи через таблицу users
      final membersResponse = await _supabase
          .from('users')
          .select('*')
          .eq('family_id', familyId);

      _familyMembers = (membersResponse as List).map((user) {
        return FamilyMember(
          id: user['id'] as String,
          name: user['name'] as String? ?? 'Неизвестный',
          role: user['user_type'] == 'parent' ? FamilyRole.parent : FamilyRole.child,
          email: user['email'] as String?,
          todayCompletedTasks: 0, // Можно добавить логику подсчета задач
          todayTotalTasks: 0,
        );
      }).toList();

      // Загружаем статистику выполненных задач
      await _loadCompletedTasksCount(familyId);

    } catch (e) {
      debugPrint('Error loading family members: $e');
      // Для демонстрации используем mock данные
      _loadMockData();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadCompletedTasksCount(String familyId) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('id')
          .eq('family_id', familyId)
          .eq('completed', true)
          .gte('updated_at', DateTime.now().subtract(const Duration(days: 30)).toIso8601String());

      _completedTasksCount = response.length;
    } catch (e) {
      debugPrint('Error loading completed tasks count: $e');
      _completedTasksCount = 24; // mock данные
    }
  }

  void _loadMockData() {
    _familyMembers = [
      FamilyMember(
        id: '1',
        name: 'Марк',
        role: FamilyRole.parent,
        todayCompletedTasks: 3,
        todayTotalTasks: 4,
      ),
      FamilyMember(
        id: '2',
        name: 'Альбина',
        role: FamilyRole.parent,
        todayCompletedTasks: 2,
        todayTotalTasks: 5,
      ),
      FamilyMember(
        id: '3',
        name: 'Вероника',
        role: FamilyRole.child,
        todayCompletedTasks: 2,
        todayTotalTasks: 2,
      ),
    ];
    _completedTasksCount = 24;
  }

  // Добавьте этот метод в класс FamilyProvider
  void clearFamilyMembers() {
    _familyMembers = [];
    _completedTasksCount = 0;
    notifyListeners();
  }
}