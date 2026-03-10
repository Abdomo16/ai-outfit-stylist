import '../models/clothing_item_model.dart';

abstract class WardrobeRepository {
  Future<List<ClothingItemModel>> getClothingItems();
  Future<ClothingItemModel> getClothingItemById(String id);
  Future<void> addClothingItem(ClothingItemModel item);
  Future<void> updateClothingItem(ClothingItemModel item);
  Future<void> deleteClothingItem(String id);
}
