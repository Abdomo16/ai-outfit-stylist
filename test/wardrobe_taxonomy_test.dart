import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_selctor/core/constants/wardrobe_taxonomy.dart';
import 'package:outfit_selctor/data/models/clothing_item_model.dart';

void main() {
  test('every type belongs to exactly one category', () {
    final seen = <String>{};
    for (final types in WardrobeTaxonomy.typesByCategory.values) {
      for (final type in types) {
        expect(seen.add(type), isTrue, reason: '$type is listed twice');
      }
    }
  });

  test('old classifier labels map to the new tabs', () {
    expect(WardrobeTaxonomy.categoryForType('Tshirts'), 'Tops');
    expect(WardrobeTaxonomy.categoryForType('Trousers'), 'Bottoms');
    expect(WardrobeTaxonomy.categoryForType('Casual Shoes'), 'Shoes');
    expect(WardrobeTaxonomy.categoryForType('Handbags'), 'Bags');
    expect(WardrobeTaxonomy.categoryForType('Watches'), 'Accessories');
    expect(WardrobeTaxonomy.categoryForType('tracksuit'), 'Bottoms');
  });

  test('a stored category that is not a tab is derived from the type', () {
    final item = ClothingItemModel.fromJson({
      'type': 'Tshirts',
      'category': 'Shirts',
      'color': 'Black',
    });
    expect(item.type, 'Tshirts');
    expect(item.category, 'Tops');
  });

  test('a recommend response keeps the type and reads wardrobeCategory', () {
    final item = ClothingItemModel.fromJson({
      'category': 'puffer jacket',
      'wardrobeCategory': 'Outerwear',
      'color': 'Navy',
    });
    expect(item.type, 'puffer jacket');
    expect(item.category, 'Outerwear');
  });

  test('saving writes the type and the tab separately', () {
    final json = ClothingItemModel(
      type: 'sneakers',
      category: 'Shoes',
      color: 'White',
    ).toJson();
    expect(json['type'], 'sneakers');
    expect(json['category'], 'Shoes');
  });
}
