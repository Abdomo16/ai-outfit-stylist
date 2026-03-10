import '../models/clothing_item_model.dart';
import 'wardrobe_repository.dart';

class WardrobeRepositoryImpl implements WardrobeRepository {
  @override
  Future<List<ClothingItemModel>> getClothingItems() async {
    // TODO: implement with Supabase
    return [];
  }

  @override
  Future<ClothingItemModel> getClothingItemById(String id) async {
    // TODO: implement with Supabase
    throw UnimplementedError();
  }

  @override
  Future<void> addClothingItem(ClothingItemModel item) async {
    // TODO: implement with Supabase
  }

  @override
  Future<void> updateClothingItem(ClothingItemModel item) async {
    // TODO: implement with Supabase
  }

  @override
  Future<void> deleteClothingItem(String id) async {
    // TODO: implement with Supabase
  }
}
