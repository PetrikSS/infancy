import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  User? _currentUser;
  bool _isLoading = true;
  String? _familyId;
  String? _userType; // 'parent' or 'child'

  AuthProvider() {
    _init();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get familyId => _familyId;
  String? get userType => _userType;

  Future<void> _init() async {
    _currentUser = _supabase.auth.currentUser;
    if (_currentUser != null) {
      await _loadUserData();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    try {
      final response = await _supabase
          .from('users')
          .select('family_id, user_type')
          .eq('id', _currentUser!.id)
          .single();

      _familyId = response['family_id'];
      _userType = response['user_type'];
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
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
        data: {
          'name': name,
          'birth_date': birthDate,
          'user_type': userType,
        },
      );

      if (response.user != null) {
        _currentUser = response.user;
        _userType = userType;

        // Ждем немного, чтобы триггер сработал
        await Future.delayed(const Duration(milliseconds: 500));
        await _loadUserData();

        notifyListeners();
      }
      return null;
    } catch (e) {
      return 'Ошибка регистрации: ${e.toString()}';
    }
  }

  Future<String?> createNewFamily() async {
    try {
      // Создаем новую семью
      final familyResponse = await _supabase
          .from('families')
          .insert({})
          .select()
          .single();

      final familyId = familyResponse['id'];

      // Присваиваем семью текущему пользователю
      await _supabase.from('users').update({
        'family_id': familyId,
      }).eq('id', _currentUser!.id);

      _familyId = familyId;
      notifyListeners();
      return null;
    } catch (e) {
      return 'Ошибка создания семьи: ${e.toString()}';
    }
  }

  Future<String?> createFamily(String partnerId) async {
    try {
      // Проверяем, существует ли партнер
      final partnerResponse = await _supabase
          .from('users')
          .select('family_id')
          .eq('id', partnerId)
          .maybeSingle();

      if (partnerResponse == null) {
        return 'Пользователь с таким ID не найден';
      }

      String familyId;

      // Если у партнера уже есть семья, присоединяемся к ней
      if (partnerResponse['family_id'] != null) {
        familyId = partnerResponse['family_id'];
      } else {
        // Если нет, создаем новую семью
        final familyResponse = await _supabase
            .from('families')
            .insert({})
            .select()
            .single();

        familyId = familyResponse['id'];

        // Присваиваем семью партнеру
        await _supabase.from('users').update({
          'family_id': familyId,
        }).eq('id', partnerId);
      }

      // Присваиваем семью текущему пользователю
      await _supabase.from('users').update({
        'family_id': familyId,
      }).eq('id', _currentUser!.id);

      _familyId = familyId;
      notifyListeners();
      return null;
    } catch (e) {
      return 'Ошибка создания семьи: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    _familyId = null;
    _userType = null;
    notifyListeners();
  }
}