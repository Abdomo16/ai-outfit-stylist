import '../models/outfit_model.dart';

abstract class OutfitRepository {
  Future<OutfitModel> generateOutfit({
    required String occasion,
    required String stylePreference,
    String? colorPreference,
  });
  Future<List<OutfitModel>> getSavedOutfits();
  Future<void> saveOutfit(OutfitModel outfit);
  Future<void> deleteOutfit(String id);
  Future<OutfitModel> analyzeOutfit(String imagePath);
}
