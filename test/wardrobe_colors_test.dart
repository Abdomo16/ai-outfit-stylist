import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_selctor/core/constants/wardrobe_colors.dart';
import 'package:outfit_selctor/data/models/clothing_item_model.dart';
import 'package:outfit_selctor/features/wardrobe/utils/wardrobe_labels.dart';
import 'package:outfit_selctor/l10n/app_localizations.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  test('the app knows the same 22 colors as the backend', () {
    expect(WardrobeColors.names.length, 22);
    expect(WardrobeColors.names, containsAll(['light grey', 'charcoal', 'tan']));
  });

  test('old stored values map to current names', () {
    expect(WardrobeColors.canonical('Indigo'), 'navy');
    expect(WardrobeColors.canonical('maroon'), 'burgundy');
    expect(WardrobeColors.canonical(' White '), 'white');
  });

  test('the measured hex wins over the name swatch', () {
    expect(
      WardrobeColors.swatchFor('white', '#efeee8'),
      const Color(0xFFEFEEE8),
    );
    expect(WardrobeColors.swatchFor('navy', null), WardrobeColors.swatches['navy']);
    expect(WardrobeColors.hexOf('white'), '#ffffff');
  });

  test('a patterned item is titled with both colors in each language', () {
    final item = ClothingItemModel.fromJson({
      'type': 'shirt',
      'color': 'navy',
      'hex': '#1f2a44',
      'secondary_color': 'white',
      'secondary_hex': '#f5f5f5',
    });

    expect(item.secondaryColor, 'white');
    expect(WardrobeLabels.title(en, item), 'Navy & White Shirt');
    expect(WardrobeLabels.title(ar, item), 'قميص كحلي وأبيض');
  });

  test('editing can remove the second color', () {
    final item = ClothingItemModel(
      type: 'shirt',
      color: 'navy',
      secondaryColor: 'white',
      secondaryHex: '#ffffff',
    );

    final single = item.copyWith(clearSecondary: true);

    expect(single.secondaryColor, isNull);
    expect(single.secondaryHex, isNull);
    expect(single.toJson()['secondary_color'], isNull);
  });
}
