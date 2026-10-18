import '../models/clothing_item_model.dart';
import '../models/pending_wardrobe_item.dart';

abstract class WardrobeRepository {
  Future<List<ClothingItemModel>> getClothingItems();
  Future<ClothingItemModel> getClothingItemById(String id);

  /// Uploads a photo. Returns the partly visible items the backend held back.
  Future<List<PendingWardrobeItem>> addClothingItem(ClothingItemModel item);

  /// Saves [keep] and drops every other pending item of the same uploads.
  /// [all] is every pending item the user was shown.
  Future<void> keepPendingItems(
    List<PendingWardrobeItem> all,
    List<PendingWardrobeItem> keep,
  );
  Future<void> updateClothingItem(ClothingItemModel item);
  Future<void> deleteClothingItem(String id);
  Future<void> deleteClothingItems(List<String> ids);
}
