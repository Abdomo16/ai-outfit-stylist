import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_selctor/data/datasources/ai_service.dart';
import 'package:outfit_selctor/data/datasources/weather_service.dart';
import 'package:outfit_selctor/data/models/clothing_item_model.dart';
import 'package:outfit_selctor/data/models/outfit_model.dart';
import 'package:outfit_selctor/data/repositories/wardrobe_repository.dart';
import 'package:outfit_selctor/data/repositories/wear_log_repository.dart';
import 'package:outfit_selctor/features/assistant/chat_cubit.dart';
import 'package:outfit_selctor/features/outfit_generator/cubit/outfit_cubit.dart';
import 'package:outfit_selctor/features/outfit_generator/cubit/outfit_state.dart';
import 'package:outfit_selctor/features/outfit_generator/utils/outfit_pieces.dart';

ClothingItemModel _item(String id, String type) =>
    ClothingItemModel(id: id, name: '', type: type, color: 'black');

final _wardrobe = [
  _item('t', 'shirt'),
  _item('b', 'jeans'),
  _item('s', 'sneakers'),
];

OutfitModel _outfit(String id, List<ClothingItemModel> items) =>
    OutfitModel(id: id, name: '', occasion: 'work', items: items);

class FakeWardrobe implements WardrobeRepository {
  List<ClothingItemModel> items = _wardrobe;

  @override
  Future<List<ClothingItemModel>> getClothingItems() async => items;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeWeather extends WeatherService {
  final bool fail;

  FakeWeather({this.fail = false});

  @override
  Future<WeatherConditions> current() async {
    if (fail) throw const LocationRequiredException();
    return const WeatherConditions(weather: 'mild', season: 'spring');
  }
}

class FakeWearLog implements WearLogRepository {
  @override
  Future<List<String>> recentItemIds({int days = 3}) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAI implements AIService {
  final recommendCalls = <Map<String, Object?>>[];
  final chatCalls = <Map<String, Object?>>[];
  final chatResults = <ChatResult>[];
  bool failChat = false;

  @override
  Future<OutfitModel> getRecommendations({
    required List<ClothingItemModel> wardrobe,
    required String occasion,
    String? style,
    required String weather,
    required String season,
    List<String> lockIds = const [],
    String? swapId,
    List<String> excludeIds = const [],
    bool layer = false,
  }) async {
    recommendCalls.add({'occasion': occasion, 'style': style});
    return _outfit('o1', wardrobe);
  }

  @override
  Future<ChatResult> chat({
    required String message,
    required List<ChatTurn> history,
    required List<ClothingItemModel> wardrobe,
    OutfitModel? currentOutfit,
    String? weather,
    String? season,
    List<String> excludeIds = const [],
    String? locale,
  }) async {
    chatCalls.add({
      'message': message,
      'history': history.map((turn) => '${turn.role}:${turn.content}').toList(),
      'current': currentOutfit?.id,
      'weather': weather,
      'locale': locale,
    });
    if (failChat) throw Exception('offline');
    return chatResults.removeAt(0);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('OutfitCubit', () {
    test('generates from an occasion alone, with no style', () async {
      final ai = FakeAI();
      final cubit = OutfitCubit(
        FakeWardrobe(),
        ai,
        weatherService: FakeWeather(),
        wearLog: FakeWearLog(),
      );
      addTearDown(cubit.close);

      cubit.selectOccasion('Date Night');
      await cubit.generateOutfit();

      expect(cubit.state, isA<OutfitGenerated>());
      expect(ai.recommendCalls, [
        {'occasion': 'date night', 'style': null},
      ]);
    });

    test('asks for an occasion when none is picked', () async {
      final cubit = OutfitCubit(
        FakeWardrobe(),
        FakeAI(),
        weatherService: FakeWeather(),
        wearLog: FakeWearLog(),
      );
      addTearDown(cubit.close);

      await cubit.generateOutfit();
      expect(cubit.state, isA<OutfitError>());
    });

    test('show() makes a chat outfit tweakable', () {
      final cubit = OutfitCubit(
        FakeWardrobe(),
        FakeAI(),
        wearLog: FakeWearLog(),
      );
      addTearDown(cubit.close);
      final outfit = _outfit('chat', _wardrobe);

      cubit.show(outfit, weather: 'cold', season: 'winter');

      expect(cubit.state, OutfitGenerated(outfit));
      expect(cubit.selectedOccasion, 'work');
      expect(cubit.lastWeather, 'cold');
    });
  });

  group('orderedPieces', () {
    test('reads outer layer down to shoes, then bags and accessories', () {
      final items = [
        _item('w', 'watch'),
        _item('s', 'sneakers'),
        _item('b', 'jeans'),
        _item('bag', 'backpack'),
        _item('t', 't-shirt'),
        _item('j', 'jacket'),
        ClothingItemModel(name: '', type: 'shirt', color: 'white'),
      ];

      expect(orderedPieces(items).map((item) => item.id), [
        'j',
        't',
        'b',
        's',
        'bag',
        'w',
      ]);
      expect(items.where(isSidePiece).map((item) => item.id), [
        'w',
        's',
        'bag',
      ]);
    });
  });

  group('ChatCubit', () {
    test('sends history and tweaks the latest outfit', () async {
      final ai = FakeAI();
      final first = _outfit('first', _wardrobe);
      ai.chatResults.addAll([
        ChatResult(reply: 'Here you go.', outfit: first),
        const ChatResult(reply: '', noMatch: true),
      ]);
      final start = _outfit('start', _wardrobe);
      final cubit = ChatCubit(
        FakeWardrobe(),
        ai,
        weatherService: FakeWeather(),
        wearLog: FakeWearLog(),
        currentOutfit: start,
      );
      addTearDown(cubit.close);

      await cubit.send('Warmer', locale: 'en');
      await cubit.send('Swap shoes');

      expect(ai.chatCalls[0]['current'], 'start');
      expect(ai.chatCalls[0]['weather'], 'mild');
      expect(ai.chatCalls[0]['history'], isEmpty);
      expect(ai.chatCalls[1]['current'], 'first');
      expect(ai.chatCalls[1]['history'], [
        'user:Warmer',
        'assistant:Here you go.',
      ]);

      final messages = cubit.state.messages;
      expect(messages.map((m) => m.fromUser), [true, false, true, false]);
      expect(messages[1].outfit, first);
      expect(messages[3].status, ChatStatus.noMatch);
      expect(cubit.state.sending, isFalse);
    });

    test('works without location and reports a failed request', () async {
      final ai = FakeAI()..failChat = true;
      final cubit = ChatCubit(
        FakeWardrobe(),
        ai,
        weatherService: FakeWeather(fail: true),
        wearLog: FakeWearLog(),
      );
      addTearDown(cubit.close);

      await cubit.send('Gym after work');

      expect(ai.chatCalls.single['weather'], isNull);
      expect(cubit.state.messages.last.status, ChatStatus.error);
    });

    test('an empty wardrobe is answered without calling the AI', () async {
      final ai = FakeAI();
      final cubit = ChatCubit(
        FakeWardrobe()..items = const [],
        ai,
        weatherService: FakeWeather(),
        wearLog: FakeWearLog(),
      );
      addTearDown(cubit.close);

      await cubit.send('hi');

      expect(ai.chatCalls, isEmpty);
      expect(cubit.state.messages.last.status, ChatStatus.emptyWardrobe);
    });
  });
}
