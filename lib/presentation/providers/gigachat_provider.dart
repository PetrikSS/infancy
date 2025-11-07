import 'package:flutter/foundation.dart';
import 'package:gigachat_dart/gigachat_dart.dart';

import '../../unsafe_io_client.dart';





class GigaChatProvider with ChangeNotifier {
  /// Можно создать клиента двумя способами:
  /// 1. Из пары clientId + clientSecret (UUID v4)
  /// 2. Из base64-токена (Basic <base64(clientId:clientSecret)>)
  ///
  /// Для простоты используем способ 2.
  final String _base64Token =
      'TOKEN';

  late final GigachatClient _client;
  bool _initialized = false;

  bool _isLoading = false;
  String? _error;
  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

/*  /// Инициализация клиента
  Future<void> init() async {
    if (_initialized) return;
    try {
      _client = GigachatClient.fromBase64(base64token: _base64Token);
      _initialized = true;
      _error = null;
    } catch (e) {
      _error = 'Ошибка инициализации GigaChat: $e';
      debugPrint(_error);
      rethrow;
    }
  }*/
  Future<void> init() async {
    if (_initialized) return;
    try {
      final ioClient = createInsecureIOClient(); // 👈
      _client = GigachatClient.fromBase64(
        base64token: _base64Token,
        client: ioClient, // 👈 передаём кастомный http-клиент
      );
      _initialized = true;
    } catch (e) {
      _error = 'Ошибка инициализации GigaChat: $e';
      rethrow;
    }
  }

  /// Отправка сообщения пользователем
  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    _messages.add(ChatMessage(
      text: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_initialized) await init();

      // Формируем историю сообщений для API
      final dialog = _messages
          .map((m) => Message(
        role: m.isUser ? MessageRole.user : MessageRole.assistant,
        content: m.text,
      ))
          .toList();

      // Запрос в GigaChat SDK
      final response = await _client.generateChatCompletion(
        request: Chat(model: 'GigaChat', messages: dialog),
      );

      final answer =
          response.choices?.first.message?.content ?? '(Пустой ответ)';

      _messages.add(ChatMessage(
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _error = null;
    } catch (e) {
      _error = 'Ошибка при обращении к GigaChat: $e';
      debugPrint(_error);
      _messages.add(ChatMessage(
        text:
        'Извините, произошла ошибка при обращении к GigaChat. Попробуйте ещё раз.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Версия с потоковой генерацией (стриминг)
  Future<void> sendMessageStream(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    _messages.add(ChatMessage(
      text: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_initialized) await init();

      final dialog = _messages
          .map((m) => Message(
        role: m.isUser ? MessageRole.user : MessageRole.assistant,
        content: m.text,
      ))
          .toList();

      String buffer = '';
      _messages.add(ChatMessage(
        text: '',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      notifyListeners();

      final index = _messages.length - 1;

      await _client
          .generateChatCompletionStream(
        request: Chat(model: 'GigaChat', messages: dialog),
      )
          .listen((event) {
        final chunk = event.choices?[0].delta?.content ?? '';
        if (chunk.isNotEmpty) {
          buffer += chunk;
          _messages[index] = ChatMessage(
            text: buffer,
            isUser: false,
            timestamp: _messages[index].timestamp,
          );
          notifyListeners();
        }
      }).asFuture();

      _error = null;
    } catch (e) {
      _error = 'Ошибка при получении потока: $e';
      debugPrint(_error);
      _messages.add(ChatMessage(
        text:
        'Извините, произошла ошибка при генерации ответа. Попробуйте позже.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Очистка истории
  void clearChat() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }

  /// Приветственное сообщение
  void addWelcomeMessage() {
    if (_messages.isEmpty) {
      _messages.add(ChatMessage(
        text:
        'Здравствуйте! Я ваш помощник GigaChat. Чем могу помочь сегодня?',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    }
  }
}

/// Простая модель сообщения
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}