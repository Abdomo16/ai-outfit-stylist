import '../../../core/constants/wardrobe_taxonomy.dart';
import '../../../data/models/clothing_item_model.dart';

class CategoryUtils {
  static bool matchesCategory(ClothingItemModel item, String selected) {
    if (selected == WardrobeTaxonomy.all) return true;
    return item.category == selected;
  }
}
