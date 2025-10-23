import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';

class TaskProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Делаем supabase публичным для доступа из EditItemScreen
  SupabaseClient get supabase => _supabase;

  List<TaskModel> _tasks = [];
  List<TaskModel> _purchases = [];
  List<TaskModel> _wishes = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  List<TaskModel> get purchases => _purchases;
  List<TaskModel> get wishes => _wishes;
  bool get isLoading => _isLoading;

  Future<void> loadTasks(String familyId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('tasks')
          .select('*, task_assignments(*)')
          .eq('family_id', familyId)
          .eq('type', 'task')
          .order('date');

      _tasks = (response as List)
          .map((json) => TaskModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPurchases(String? familyId) async {
    try {
      print('Loading purchases for familyId: $familyId');

      final response = await _supabase
          .from('tasks')
          .select()
          .eq('type', 'purchase');

      _purchases = (response as List)
          .map((json) => TaskModel.fromJson(json))
          .toList();

      notifyListeners();
      print('Successfully loaded ${_purchases.length} purchases total');

    } catch (e) {
      debugPrint('Error loading purchases: $e');
    }
  }

  Future<void> loadWishes(String? familyId) async {
    try {
      if (familyId != null) {
        final response = await _supabase
            .from('tasks')
            .select()
            .eq('family_id', familyId)
            .eq('type', 'wish');

        _wishes = (response as List)
            .map((json) => TaskModel.fromJson(json))
            .toList();
      } else {
        final response = await _supabase
            .from('tasks')
            .select()
            .filter('family_id', 'is', null)
            .eq('type', 'wish');

        _wishes = (response as List)
            .map((json) => TaskModel.fromJson(json))
            .toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading wishes: $e');
    }
  }

  // Получение задач на сегодня
  List<TaskModel> getTodayTasks() {
    final today = DateTime.now();
    return _tasks.where((task) {
      if (task.date == null) return false;
      return task.date!.year == today.year &&
          task.date!.month == today.month &&
          task.date!.day == today.day;
    }).toList();
  }

  // Получение задач на текущий месяц
  List<TaskModel> getMonthTasks() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return _tasks.where((task) {
      if (task.date == null) return false;
      return task.date!.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
          task.date!.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  Future<String?> createTask({
    required String? familyId,
    required String title,
    required String type,
    String? category,
    String? description,
    DateTime? date,
    List<String>? assignedUserIds,
  }) async {
    try {
      print('Creating task: $title, type: $type, familyId: $familyId, category: $category');

      final taskData = {
        'family_id': familyId,
        'title': title,
        'type': type,
        'category': category,
        'description': description,
        'date': date?.toIso8601String(),
        'completed': false,
      };

      taskData.removeWhere((key, value) => value == null);

      print('Task data: $taskData');

      final taskResponse = await _supabase
          .from('tasks')
          .insert(taskData)
          .select()
          .single();

      print('Task created successfully: ${taskResponse['id']}');

      // ОБНОВЛЯЕМ СПИСКИ ПОСЛЕ СОЗДАНИЯ
      if (type == 'purchase') {
        await loadPurchases(familyId);
      } else if (type == 'wish') {
        await loadWishes(familyId);
      } else {
        if (familyId != null) {
          await loadTasks(familyId);
        }
      }

      return null;
    } catch (e) {
      print('Error creating task: $e');
      return 'Ошибка создания задачи: ${e.toString()}';
    }
  }

  void toggleTaskCompletion(String taskId, bool completed) {
    // Обновляем в tasks
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(completed: completed);
      notifyListeners();
      _updateTaskInDatabase(_tasks[taskIndex]);
    }

    // Обновляем в purchases
    final purchaseIndex = _purchases.indexWhere((p) => p.id == taskId);
    if (purchaseIndex != -1) {
      _purchases[purchaseIndex] = _purchases[purchaseIndex].copyWith(completed: completed);
      notifyListeners();
      _updateTaskInDatabase(_purchases[purchaseIndex]);
    }

    // Обновляем в wishes
    final wishIndex = _wishes.indexWhere((w) => w.id == taskId);
    if (wishIndex != -1) {
      _wishes[wishIndex] = _wishes[wishIndex].copyWith(completed: completed);
      notifyListeners();
      _updateTaskInDatabase(_wishes[wishIndex]);
    }
  }

  Future<void> _updateTaskInDatabase(TaskModel task) async {
    try {
      final taskData = {
        'completed': task.completed,
        'title': task.title,
        'category': task.category,
        'description': task.description,
        'date': task.date?.toIso8601String(),
      };

      taskData.removeWhere((key, value) => value == null);

      await _supabase
          .from('tasks')
          .update(taskData)
          .eq('id', task.id);

      print('Task updated in database: ${task.id}');
    } catch (e) {
      debugPrint('Error updating task in database: $e');
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    final taskToDelete = _tasks.firstWhere((t) => t.id == taskId, orElse: () => _tasks.isNotEmpty ? _tasks[0] : TaskModel(
      id: '',
      familyId: null,
      title: '',
      type: TaskType.task,
    ));

    _tasks.removeWhere((t) => t.id == taskId);
    _purchases.removeWhere((p) => p.id == taskId);
    _wishes.removeWhere((w) => w.id == taskId);

    notifyListeners();
    _deleteTaskFromDatabase(taskId);
  }

  Future<void> _deleteTaskFromDatabase(String taskId) async {
    try {
      await _supabase
          .from('tasks')
          .delete()
          .eq('id', taskId);

      print('Task deleted from database: $taskId');
    } catch (e) {
      debugPrint('Error deleting task from database: $e');
    }
  }

  List<TaskModel> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      if (task.date == null) return false;
      return task.date!.year == date.year &&
          task.date!.month == date.month &&
          task.date!.day == date.day;
    }).toList();
  }

  List<TaskModel> getPersonalPurchases() {
    return _purchases.where((p) => p.category == 'personal').toList();
  }

  List<TaskModel> getFamilyPurchases() {
    return _purchases.where((p) => p.category == 'family').toList();
  }

  Future<void> loadPersonalPurchases() async {
    await loadPurchases(null);
  }

  // Добавляем этот метод в класс TaskProvider
  Future<String?> updateTask({
    required String taskId,
    required String title,
    String? category,
    String? description,
    DateTime? date,
  }) async {
    try {
      final updatedData = {
        'title': title,
        'category': category,
        'description': description,
        'date': date?.toIso8601String(),
      };

      // Убираем null значения
      updatedData.removeWhere((key, value) => value == null);

      await _supabase
          .from('tasks')
          .update(updatedData)
          .eq('id', taskId);

      // Обновляем локальные данные
      _updateLocalTaskData(taskId, title, category, description, date);

      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Error updating task: $e');
      return 'Ошибка обновления: ${e.toString()}';
    }
  }

// Вспомогательный метод для обновления локальных данных
  void _updateLocalTaskData(
      String taskId,
      String title,
      String? category,
      String? description,
      DateTime? date
      ) {
    // Обновляем в tasks
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(
        title: title,
        category: category,
        description: description,
        date: date,
      );
    }

    // Обновляем в purchases
    final purchaseIndex = _purchases.indexWhere((p) => p.id == taskId);
    if (purchaseIndex != -1) {
      _purchases[purchaseIndex] = _purchases[purchaseIndex].copyWith(
        title: title,
        category: category,
        description: description,
      );
    }

    // Обновляем в wishes
    final wishIndex = _wishes.indexWhere((w) => w.id == taskId);
    if (wishIndex != -1) {
      _wishes[wishIndex] = _wishes[wishIndex].copyWith(
        title: title,
        category: category,
        description: description,
      );
    }
  }





}