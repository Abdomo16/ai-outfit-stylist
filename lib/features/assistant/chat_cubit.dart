import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/ai_service.dart';
import '../../data/datasources/weather_service.dart';
import '../../data/models/clothing_item_model.dart';
import '../../data/models/outfit_model.dart';
import '../../data/repositories/wardrobe_repository.dart';
import '../../data/repositories/wear_log_repository.dart';

enum ChatStatus { ok, noMatch, emptyWardrobe, error }

class ChatMessage {
  final bool fromUser;
  final String text;
  final OutfitModel? outfit;
  final ChatStatus status;

  const ChatMessage({
    required this.fromUser,
    required this.text,
    this.outfit,
    this.status = ChatStatus.ok,
  });
}

class ChatState {
  final List<ChatMessage> messages;
  final bool sending;

  const ChatState({this.messages = const [], this.sending = false});
}

class ChatCubit extends Cubit<ChatState> {
  final WardrobeRepository _wardrobeRepo;
  final AIService _aiService;
  final WeatherService _weatherService;
  final WearLogRepository _wearLog;

  List<ClothingItemModel>? _wardrobe;
  WeatherConditions? _conditions;
  bool _conditionsLoaded = false;

  /// The look the next message tweaks: the latest outfit in the chat, or
  /// the one the chat was opened from.
  OutfitModel? currentOutfit;

  ChatCubit(
    this._wardrobeRepo,
    this._aiService, {
    WeatherService? weatherService,
    WearLogRepository? wearLog,
    this.currentOutfit,
  }) : _weatherService = weatherService ?? WeatherService(),
       _wearLog = wearLog ?? WearLogRepository(),
       super(const ChatState());

  String? get weather => _conditions?.weather;
  String? get season => _conditions?.season;

  Future<void> send(String text, {String? locale}) async {
    final message = text.trim();
    if (message.isEmpty || state.sending) return;

    final history = [
      for (final previous in state.messages)
        if (previous.text.isNotEmpty)
          ChatTurn(
            role: previous.fromUser ? 'user' : 'assistant',
            content: previous.text,
          ),
    ];
    final withUser = [
      ...state.messages,
      ChatMessage(fromUser: true, text: message),
    ];
    emit(ChatState(messages: withUser, sending: true));

    try {
      final wardrobe = _wardrobe ??= await _wardrobeRepo.getClothingItems();
      if (wardrobe.isEmpty) {
        _wardrobe = null;
        _reply(withUser, const ChatMessage(
          fromUser: false,
          text: '',
          status: ChatStatus.emptyWardrobe,
        ));
        return;
      }
      await _loadConditions();
      List<String> excludeIds = const [];
      try {
        excludeIds = await _wearLog.recentItemIds();
      } catch (_) {}

      final result = await _aiService.chat(
        message: message,
        history: history,
        wardrobe: wardrobe,
        currentOutfit: currentOutfit,
        weather: weather,
        season: season,
        excludeIds: excludeIds,
        locale: locale,
      );
      if (result.outfit != null) currentOutfit = result.outfit;
      _reply(withUser, ChatMessage(
        fromUser: false,
        text: result.reply,
        outfit: result.outfit,
        status: result.noMatch ? ChatStatus.noMatch : ChatStatus.ok,
      ));
    } catch (_) {
      _reply(withUser, const ChatMessage(
        fromUser: false,
        text: '',
        status: ChatStatus.error,
      ));
    }
  }

  void _reply(List<ChatMessage> messages, ChatMessage reply) {
    emit(ChatState(messages: [...messages, reply]));
  }

  /// Weather helps but is optional here, so a missing location is fine.
  Future<void> _loadConditions() async {
    if (_conditionsLoaded) return;
    _conditionsLoaded = true;
    try {
      _conditions = await _weatherService.current();
    } catch (_) {
      _conditions = null;
    }
  }
}
