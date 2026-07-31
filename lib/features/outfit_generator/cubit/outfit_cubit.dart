import 'package:flutter_bloc/flutter_bloc.dart';
import 'outfit_state.dart';

import '../../../../data/datasources/ai_service.dart';
import '../../../../data/repositories/wardrobe_repository.dart';

class OutfitCubit extends Cubit<OutfitState> {
  final WardrobeRepository _wardrobeRepo;
  final AIService _aiService;

  OutfitCubit(this._wardrobeRepo, this._aiService)
    : super(const OutfitInitial());

  String? selectedOccasion;
  String? selectedStyle;

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

  void generateOutfit() async {
    if (selectedOccasion == null || selectedStyle == null) {
      emit(const OutfitError("Please select both an occasion and a style."));
      return;
    }

    emit(OutfitLoading());

    try {
      final wardrobe = await _wardrobeRepo.getClothingItems();
      if (wardrobe.isEmpty) {
        emit(
          const OutfitError("Your wardrobe is empty. Please add items first."),
        );
        return;
      }

      final recommendation = await _aiService.getRecommendations(
        wardrobe: wardrobe,
        occasion: selectedOccasion!.toLowerCase(),
        weather: _weatherForOccasion(selectedOccasion!),
        season: _seasonForOccasion(selectedOccasion!),
      );

      emit(OutfitGenerated(recommendation));
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('404') || msg.contains('No valid combinations')) {
        emit(
          const OutfitError(
            "No matching outfit found. Try a different occasion or add more clothes to your wardrobe!",
          ),
        );
      } else {
        emit(OutfitError("Failed to generate outfit: $msg"));
      }
    }
  }

  String _weatherForOccasion(String occasion) {
    switch (occasion.toLowerCase()) {
      case 'gym':
        return 'warm';
      case 'party':
        return 'warm';
      case 'travel':
        return 'mild';
      default:
        return 'sunny';
    }
  }

  String _seasonForOccasion(String occasion) {
    switch (occasion.toLowerCase()) {
      case 'gym':
        return 'summer';
      case 'travel':
        return 'all';
      default:
        return 'summer';
    }
  }
}
