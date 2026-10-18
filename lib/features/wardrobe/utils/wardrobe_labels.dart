import '../../../core/constants/wardrobe_colors.dart';
import '../../../core/constants/wardrobe_taxonomy.dart';
import '../../../data/models/clothing_item_model.dart';
import '../../../l10n/app_localizations.dart';

class WardrobeLabels {
  static String category(AppLocalizations l10n, String category) {
    switch (category) {
      case WardrobeTaxonomy.all:
        return l10n.categoryAll;
      case 'Tops':
        return l10n.categoryTops;
      case 'Bottoms':
        return l10n.categoryBottoms;
      case 'Outerwear':
        return l10n.categoryOuterwear;
      case 'Dresses':
        return l10n.categoryDresses;
      case 'Shoes':
        return l10n.categoryShoes;
      case 'Bags':
        return l10n.categoryBags;
      case 'Accessories':
        return l10n.categoryAccessories;
      default:
        return category;
    }
  }

  static String type(AppLocalizations l10n, String type) {
    switch (WardrobeTaxonomy.canonicalType(type)) {
      case 't-shirt':
        return l10n.typeTShirt;
      case 'shirt':
        return l10n.typeShirt;
      case 'blouse':
        return l10n.typeBlouse;
      case 'polo':
        return l10n.typePolo;
      case 'tank top':
        return l10n.typeTankTop;
      case 'sweater':
        return l10n.typeSweater;
      case 'hoodie':
        return l10n.typeHoodie;
      case 'sweatshirt':
        return l10n.typeSweatshirt;
      case 'cardigan':
        return l10n.typeCardigan;
      case 'jeans':
        return l10n.typeJeans;
      case 'trousers':
        return l10n.typeTrousers;
      case 'chinos':
        return l10n.typeChinos;
      case 'joggers':
        return l10n.typeJoggers;
      case 'shorts':
        return l10n.typeShorts;
      case 'skirt':
        return l10n.typeSkirt;
      case 'leggings':
        return l10n.typeLeggings;
      case 'jacket':
        return l10n.typeJacket;
      case 'denim jacket':
        return l10n.typeDenimJacket;
      case 'leather jacket':
        return l10n.typeLeatherJacket;
      case 'puffer jacket':
        return l10n.typePufferJacket;
      case 'coat':
        return l10n.typeCoat;
      case 'blazer':
        return l10n.typeBlazer;
      case 'vest':
        return l10n.typeVest;
      case 'dress':
        return l10n.typeDress;
      case 'jumpsuit':
        return l10n.typeJumpsuit;
      case 'sneakers':
        return l10n.typeSneakers;
      case 'boots':
        return l10n.typeBoots;
      case 'heels':
        return l10n.typeHeels;
      case 'flats':
        return l10n.typeFlats;
      case 'sandals':
        return l10n.typeSandals;
      case 'flip flops':
        return l10n.typeFlipFlops;
      case 'loafers':
        return l10n.typeLoafers;
      case 'formal shoes':
        return l10n.typeFormalShoes;
      case 'handbag':
        return l10n.typeHandbag;
      case 'backpack':
        return l10n.typeBackpack;
      case 'crossbody bag':
        return l10n.typeCrossbodyBag;
      case 'tote bag':
        return l10n.typeToteBag;
      case 'wallet':
        return l10n.typeWallet;
      case 'cap':
        return l10n.typeCap;
      case 'hat':
        return l10n.typeHat;
      case 'sunglasses':
        return l10n.typeSunglasses;
      case 'watch':
        return l10n.typeWatch;
      case 'belt':
        return l10n.typeBelt;
      case 'scarf':
        return l10n.typeScarf;
      case 'tie':
        return l10n.typeTie;
      case 'socks':
        return l10n.typeSocks;
      case 'jewelry':
        return l10n.typeJewelry;
      default:
        return type;
    }
  }

  static String color(AppLocalizations l10n, String? color) {
    switch (WardrobeColors.canonical(color)) {
      case 'white':
        return l10n.colorWhite;
      case 'cream':
        return l10n.colorCream;
      case 'beige':
        return l10n.colorBeige;
      case 'tan':
        return l10n.colorTan;
      case 'khaki':
        return l10n.colorKhaki;
      case 'brown':
        return l10n.colorBrown;
      case 'light grey':
        return l10n.colorLightGrey;
      case 'grey':
        return l10n.colorGrey;
      case 'charcoal':
        return l10n.colorCharcoal;
      case 'black':
        return l10n.colorBlack;
      case 'navy':
        return l10n.colorNavy;
      case 'blue':
        return l10n.colorBlue;
      case 'light blue':
        return l10n.colorLightBlue;
      case 'teal':
        return l10n.colorTeal;
      case 'green':
        return l10n.colorGreen;
      case 'olive':
        return l10n.colorOlive;
      case 'yellow':
        return l10n.colorYellow;
      case 'orange':
        return l10n.colorOrange;
      case 'red':
        return l10n.colorRed;
      case 'burgundy':
        return l10n.colorBurgundy;
      case 'pink':
        return l10n.colorPink;
      case 'purple':
        return l10n.colorPurple;
      default:
        final value = (color ?? '').trim();
        if (value.isEmpty) return value;
        return value[0].toUpperCase() + value.substring(1);
    }
  }

  /// "Navy" or "Navy & White", in the app's language.
  static String colors(AppLocalizations l10n, ClothingItemModel item) {
    final first = color(l10n, item.color);
    final second = item.secondaryColor;
    if (second == null || second.isEmpty) return first;
    return l10n.twoColors(first, color(l10n, second));
  }

  /// The user's name for the item, or its colors and type when it has none.
  static String title(AppLocalizations l10n, ClothingItemModel item) {
    final name = item.name.trim();
    if (name.isNotEmpty && name.toLowerCase() != item.type.toLowerCase()) {
      return name;
    }
    return l10n.itemTitle(colors(l10n, item), type(l10n, item.type));
  }
}
