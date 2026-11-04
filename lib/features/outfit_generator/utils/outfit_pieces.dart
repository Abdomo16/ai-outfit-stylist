import '../../../data/models/clothing_item_model.dart';

/// Wardrobe tabs in the order an outfit is read: outer layer down to shoes,
/// then what is carried and worn on top.
const List<String> pieceOrder = [
  'Outerwear',
  'Tops',
  'Dresses',
  'Bottoms',
  'Shoes',
  'Bags',
  'Accessories',
];

/// Tabs drawn small beside the main garments in the outfit preview.
const Set<String> sidePieceCategories = {'Shoes', 'Bags', 'Accessories'};

int _rank(ClothingItemModel item) {
  final index = pieceOrder.indexOf(item.category ?? '');
  return index == -1 ? pieceOrder.length : index;
}

/// The outfit's real pieces, outer layer first. Items without an id are
/// placeholders and are left out.
List<ClothingItemModel> orderedPieces(List<ClothingItemModel> items) {
  final pieces = [
    for (var i = 0; i < items.length; i++)
      if (items[i].id != null) (i, items[i]),
  ];
  pieces.sort((a, b) {
    final byRank = _rank(a.$2).compareTo(_rank(b.$2));
    return byRank != 0 ? byRank : a.$1.compareTo(b.$1);
  });
  return [for (final piece in pieces) piece.$2];
}

bool isSidePiece(ClothingItemModel item) =>
    sidePieceCategories.contains(item.category);
