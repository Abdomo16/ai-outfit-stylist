import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/models/clothing_item_model.dart';
import '../../../../data/models/outfit_model.dart';
import 'outfit_state.dart';

class OutfitCubit extends Cubit<OutfitState> {
  OutfitCubit() : super(const OutfitInitial());

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

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    try {
      final mockOutfit = _getMockOutfit(selectedOccasion!, selectedStyle!);
      emit(OutfitGenerated(mockOutfit));
    } catch (e) {
      emit(OutfitError("Failed to generate outfit: ${e.toString()}"));
    }
  }

  OutfitModel _getMockOutfit(String occasion, String style) {
    // Generate a basic mock outfit based on selection for realism
    final uuid = const Uuid().v4();

    return OutfitModel(
      id: uuid,
      name: "Clean & Casual $occasion Look",
      occasion: occasion,
      stylePreference: style,
      explanation:
          "Perfect for $occasion. Comfortable, clean and stylish in a $style way.",
      top: ClothingItemModel(
        id: '${uuid}_top',
        name: "White Oxford Shirt",
        category: "Shirts",
        color: "White",
        imageUrl: "assets/images/clothes_placeholders/shirt.png",
      ),
      bottom: ClothingItemModel(
        id: '${uuid}_bottom',
        name: "Slim Black Jeans",
        category: "Pants",
        color: "Black",
        imageUrl: "assets/images/clothes_placeholders/pants.png",
      ),
      shoes: ClothingItemModel(
        id: '${uuid}_shoes',
        name: "Minimal White Sneakers",
        category: "Shoes",
        color: "White",
        imageUrl: "assets/images/clothes_placeholders/shoes.png",
      ),
    );
  }
}
