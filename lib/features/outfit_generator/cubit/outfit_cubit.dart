import 'package:flutter_bloc/flutter_bloc.dart';
import 'outfit_state.dart';

import '../../../../data/datasources/ai_service.dart';
import '../../../../data/datasources/weather_service.dart';
import '../../../../data/models/outfit_model.dart';
import '../../../../data/repositories/wardrobe_repository.dart';
import '../../../../data/repositories/wear_log_repository.dart';

class OutfitCubit extends Cubit<OutfitState> {
  final WardrobeRepository _wardrobeRepo;
  final AIService _aiService;
  final WeatherService _weatherService;

  final WearLogRepository _wearLog;
  String? lastWeather;
  String? lastSeason;

  OutfitCubit(
    this._wardrobeRepo,
    this._aiService, {
    WeatherService? weatherService,
    WearLogRepository? wearLog,
  }) : _weatherService = weatherService ?? WeatherService(),
       _wearLog = wearLog ?? WearLogRepository(),
       super(const OutfitInitial());

  String? selectedOccasion;
  final Set<String> lockIds = {};
  bool _isGenerating = false;

  void selectOccasion(String occasion) {
    selectedOccasion = occasion;
    lockIds.clear();
    emit(OutfitInitial(selectedOccasion: selectedOccasion));
  }

  Future<void> generateToday() {
    selectedOccasion = 'everyday';
    lockIds.clear();
    return generateOutfit();
  }

  /// Shows an outfit made elsewhere, such as the AI chat, so it can be
  /// pinned, swapped and regenerated like a generated one.
  void show(OutfitModel outfit, {String? weather, String? season}) {
    selectedOccasion = outfit.occasion;
    lastWeather = weather ?? lastWeather;
    lastSeason = season ?? lastSeason;
    lockIds.clear();
    emit(OutfitGenerated(outfit));
  }

  Future<void> toggleLock(String id) {
    if (!lockIds.add(id)) {
      lockIds.remove(id);
    }
    return generateOutfit();
  }

  Future<void> swapPiece(String id) {
    lockIds.remove(id);
    return generateOutfit(swapId: id);
  }

  Future<void> generateOutfit({String? swapId}) async {
    if (_isGenerating) return;

    if (selectedOccasion == null) {
      emit(const OutfitError("Please pick an occasion."));
      return;
    }

    final previousOutfit = switch (state) {
      OutfitGenerated(:final outfit) => outfit,
      OutfitLoading(:final previousOutfit) => previousOutfit,
      OutfitError(:final previousOutfit) => previousOutfit,
      _ => null,
    };
    _isGenerating = true;
    emit(OutfitLoading(previousOutfit: previousOutfit));

    try {
      final wardrobe = await _wardrobeRepo.getClothingItems();
      if (wardrobe.isEmpty) {
        emit(
          OutfitError(
            "Your wardrobe is empty. Please add items first.",
            previousOutfit: previousOutfit,
          ),
        );
        return;
      }

      final conditions = await _weatherService.current();
      lastWeather = conditions.weather;
      lastSeason = conditions.season;
      List<String> excludeIds = const [];
      try {
        excludeIds = await _wearLog.recentItemIds();
      } catch (_) {}
      final recommendation = await _aiService.getRecommendations(
        wardrobe: wardrobe,
        occasion: selectedOccasion!.toLowerCase(),
        weather: conditions.weather,
        season: conditions.season,
        lockIds: lockIds.toList(),
        swapId: swapId,
        excludeIds: excludeIds,
      );

      emit(OutfitGenerated(recommendation));
    } on LocationRequiredException catch (e) {
      emit(OutfitError(e.message, previousOutfit: previousOutfit));
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('404') || msg.contains('No valid combinations')) {
        emit(
          OutfitError(
            "No matching outfit found. Try a different occasion or add more clothes to your wardrobe!",
            previousOutfit: previousOutfit,
          ),
        );
      } else {
        emit(
          OutfitError(
            "Failed to generate outfit. Please check your connection and try again.",
            previousOutfit: previousOutfit,
          ),
        );
      }
    } finally {
      _isGenerating = false;
    }
  }
}
