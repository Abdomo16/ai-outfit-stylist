/// Wardrobe tabs and the detailed types inside each one.
///
/// Mirrors `models/taxonomy.py` in the AI backend. The backend stores the
/// category in `wardrobe_items.category` and the type in `wardrobe_items.type`.
class WardrobeTaxonomy {
  static const String all = 'All';

  static const List<String> categories = [
    'Tops',
    'Bottoms',
    'Outerwear',
    'Dresses',
    'Shoes',
    'Bags',
    'Accessories',
  ];

  static const Map<String, List<String>> typesByCategory = {
    'Tops': [
      't-shirt',
      'shirt',
      'blouse',
      'polo',
      'tank top',
      'sweater',
      'hoodie',
      'sweatshirt',
      'cardigan',
    ],
    'Bottoms': [
      'jeans',
      'trousers',
      'chinos',
      'joggers',
      'shorts',
      'skirt',
      'leggings',
    ],
    'Outerwear': [
      'jacket',
      'denim jacket',
      'leather jacket',
      'puffer jacket',
      'coat',
      'blazer',
      'vest',
    ],
    'Dresses': ['dress', 'jumpsuit'],
    'Shoes': [
      'sneakers',
      'boots',
      'heels',
      'flats',
      'sandals',
      'flip flops',
      'loafers',
      'formal shoes',
    ],
    'Bags': ['handbag', 'backpack', 'crossbody bag', 'tote bag', 'wallet'],
    'Accessories': [
      'cap',
      'hat',
      'sunglasses',
      'watch',
      'belt',
      'scarf',
      'tie',
      'socks',
      'jewelry',
    ],
  };

  /// Labels written by the old 23-class classifier and pants refiner.
  static const Map<String, String> _legacyTypes = {
    'tshirts': 't-shirt',
    'shirts': 'shirt',
    'tops': 't-shirt',
    'kurtas': 'shirt',
    'tracksuit': 'joggers',
    'casual shoes': 'sneakers',
    'sports shoes': 'sneakers',
    'backpacks': 'backpack',
    'handbags': 'handbag',
    'wallets': 'wallet',
    'belts': 'belt',
    'watches': 'watch',
  };

  /// Old labels with no matching type that still belong to a tab.
  static const Map<String, String> _legacyCategories = {
    'briefs': 'Accessories',
    'perfume and body mist': 'Accessories',
  };

  static final Map<String, String> _categoryByType = {
    for (final entry in typesByCategory.entries)
      for (final type in entry.value) type: entry.key,
  };

  static bool isCategory(String? value) =>
      value != null && categories.contains(value);

  static String _normalize(String type) =>
      type.trim().toLowerCase().replaceAll('_', ' ');

  /// The current type for a stored label, mapping old classifier labels.
  static String canonicalType(String type) {
    final key = _normalize(type);
    if (_categoryByType.containsKey(key)) return key;
    return _legacyTypes[key] ?? key;
  }

  /// The tab a type belongs to, or null when the label is unknown.
  static String? categoryForType(String? type) {
    if (type == null || type.isEmpty) return null;
    final canonical = canonicalType(type);
    return _categoryByType[canonical] ?? _legacyCategories[canonical];
  }

  static List<String> typesFor(String category) =>
      typesByCategory[category] ?? const [];
}
