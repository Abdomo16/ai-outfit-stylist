import 'clothing_item_model.dart';

class OutfitModel {
  final String id;
  final String name;
  final String occasion;
  final String stylePreference;
  final ClothingItemModel? top;
  final ClothingItemModel? bottom;
  final ClothingItemModel? shoes;
  final ClothingItemModel? accessories;
  final String explanation;
  final String? imageUrl; // For saved/analyzed outfits

  OutfitModel({
    required this.id,
    required this.name,
    required this.occasion,
    required this.stylePreference,
    this.top,
    this.bottom,
    this.shoes,
    this.accessories,
    required this.explanation,
    this.imageUrl,
  });
}
