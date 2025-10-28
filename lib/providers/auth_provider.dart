import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  User? _currentUser;
  bool _isLoading = true;
  String? _familyId;
  String? _userType;
  String? _userName;

  AuthProvider() {
    _init();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get familyId => _familyId;
  String? get userType => _userType;
  String? get userName => _userName;

  Future<void> _init() async {
    //await _supabase.auth.refreshSession();
    _currentUser = _supabase.auth.currentUser;
    if (_currentUser != null) {
      await _loadUserData();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    try {
      debugPrint('Current user: ${_currentUser?.id}');
      debugPrint('Session: ${_supabase.auth.currentSession}');
      final response = await _supabase
          .from('users')
          .select('family_id, user_type, name')
          .eq('id', _currentUser!.id)
          .single();

      _familyId = response['family_id'];
      _userType = response['user_type'];
      _userName = response['name'];

      // Если имя не найдено, используем email без домена
      if (_userName == null) {
        final email = _currentUser!.email ?? '';
        _userName = _extractNameFromEmail(email);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      // Если произошла ошибка, все равно пытаемся извлечь имя из email
      if (_currentUser?.email != null) {
        _userName = _extractNameFromEmail(_currentUser!.email!);
      }
    }
  }

  // Метод для извлечения имени из email
  String _extractNameFromEmail(String email) {
    final parts = email.split('@');
    if (parts.isNotEmpty) {
      return parts[0];
    }
    return 'Пользователь';
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _currentUser = response.user;
      await _loadUserData();
      notifyListeners();
      return null;
    } catch (e) {
      return 'Ошибка входа: ${e.toString()}';
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String birthDate,
    required String userType,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        _userType = userType;
        _userName = name;


        await _supabase.from('users').update({
          'birth_date': birthDate,
          'user_type': userType,
          'name': name,
          //'family_id': familyId,
          // 'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', _currentUser!.id);
        // // Создаем запись в таблице users с именем
        // await _supabase.from('users').insert({
        //   'id': _currentUser!.id,
        //   'email': email,
        //   'name': name,
        //   'birth_date': birthDate,
        //   'user_type': userType,
        //   'family_id': null,
        // });

        notifyListeners();
      }
      return null;
    } catch (e) {
      return 'Ошибка регистрации: ${e.toString()}';
    }
  }

  // Создание новой семьи (для первого пользователя)
  Future<String?> createNewFamily() async {
    try {
      debugPrint('Creating family for user: ${_currentUser!.id}');

      // Создаем новую запись семьи
      final familyResponse = await _supabase
          .from('families')
          .insert({
        'created_at': DateTime.now().toIso8601String(),
      })
          .select()
          .single();

      final familyId = familyResponse['id'] as String;
      debugPrint('Family created with ID: $familyId');

      // Привязываем текущего пользователя к новой семье
      await _supabase.from('users').update({
        'family_id': familyId,
       // 'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', _currentUser!.id);

      debugPrint('User updated with family_id: $familyId');

      // Обновляем локальное состояние
      _familyId = familyId;
      notifyListeners();

      return null;
    } catch (e) {
      debugPrint('Error creating family: $e');
      return 'Ошибка создания семьи: ${e.toString()}';
    }
  }

// Присоединение к существующей семье (по ID семьи)
  Future<String?> joinFamily(String familyId) async {
    try {
      debugPrint('Searching for family with ID: $familyId');

      // Проверяем, существует ли такая семья
      final familyResponse = await _supabase
          .from('families')
          .select('id, created_at')
          .eq('id', familyId)
          .maybeSingle();

      if (familyResponse == null) {
        return 'Семья с таким ID не найдена. Проверьте правильность введённого ключа.';
      }

      debugPrint('Family found: $familyId');

      // Привязываем текущего пользователя к этой семье
      await _supabase.from('users').update({
        'family_id': familyId,
       // 'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', _currentUser!.id);

      // Обновляем локальные данные
      _familyId = familyId;
      await _loadUserData();
      notifyListeners();

      debugPrint('User successfully joined family: $familyId');

      return null;
    } catch (e) {
      debugPrint('Error joining family: $e');
      return 'Ошибка присоединения к семье: ${e.toString()}';
    }
  }

  Future<String?> updateUserName(String newName) async {
    try {
      await _supabase
          .from('users')
          .update({'name': newName})
          .eq('id', _currentUser!.id);

      _userName = newName;
      notifyListeners();
      return null;
    } catch (e) {
      return 'Ошибка обновления имени: ${e.toString()}';
    }
  }

  Future<String?> updateUserRole(String newRole) async {
    try {
      await _supabase
          .from('users')
          .update({'user_type': newRole})
          .eq('id', _currentUser!.id);

      _userType = newRole;
      notifyListeners();
      return null;
    } catch (e) {
      return 'Ошибка обновления роли: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    _familyId = null;
    _userType = null;
    _userName = null;
    notifyListeners();
  }

  Future<String?> leaveFamily() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 'Пользователь не авторизован';

      // Обновляем пользователя, удаляя family_id
      await _supabase
          .from('users')
          .update({
        'family_id': null,
        // TODO Добавить
        //'updated_at': DateTime.now().toIso8601String()
      })
          .eq('id', user.id);

      // Обновляем локальное состояние
      _familyId = null;
      notifyListeners();

      return null; // Успех
    } catch (e) {
      debugPrint('Error leaving family: $e');
      return 'Ошибка при выходе из семьи: $e';
    }
  }
}