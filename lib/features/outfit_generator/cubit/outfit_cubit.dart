import 'package:flutter_bloc/flutter_bloc.dart';
import 'outfit_state.dart';

import '../../../../data/datasources/ai_service.dart';
import '../../../../data/datasources/weather_service.dart';
import '../../../../data/repositories/wardrobe_repository.dart';

class OutfitCubit extends Cubit<OutfitState> {
  final WardrobeRepository _wardrobeRepo;
  final AIService _aiService;
  final WeatherService _weatherService;

  OutfitCubit(this._wardrobeRepo, this._aiService, {WeatherService? weatherService})
    : _weatherService = weatherService ?? WeatherService(),
      super(const OutfitInitial());

  String? selectedOccasion;
  String? selectedStyle;
  final Set<String> lockIds = {};
  bool _isGenerating = false;

  void selectOccasion(String occasion) {
    selectedOccasion = occasion;
    emit(
      OutfitInitial(
        selectedOccasion: selectedOccasion,
        selectedStyle: selectedStyle,
      ),
    ); // Re-emit to trigger UI update
  }

  void selectStyle(String style) {
    selectedStyle = style;
    emit(
      OutfitInitial(
        selectedOccasion: selectedOccasion,
        selectedStyle: selectedStyle,
      ),
    );
  }

  Future<void> generateToday() {
    selectedOccasion = 'everyday';
    selectedStyle = null;
    lockIds.clear();
    return generateOutfit();
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
      emit(const OutfitError("Please select both an occasion and a style."));
      return;
    }
    if (selectedOccasion != 'everyday' && selectedStyle == null) {
      emit(const OutfitError("Please select both an occasion and a style."));
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
      final recommendation = await _aiService.getRecommendations(
        wardrobe: wardrobe,
        occasion: selectedOccasion!.toLowerCase(),
        style: selectedStyle?.toLowerCase(),
        weather: conditions.weather,
        season: conditions.season,
        lockIds: lockIds.toList(),
        swapId: swapId,
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
