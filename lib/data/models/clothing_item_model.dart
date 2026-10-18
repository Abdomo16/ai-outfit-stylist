import '../../core/constants/wardrobe_taxonomy.dart';

class ClothingItemModel {
  final String? id;
  final String? imageUrl;
  final String name;

  /// Detailed label, e.g. "jeans" or "sneakers".
  final String type;

  /// Wardrobe tab, e.g. "Bottoms". Null when the type is unknown.
  final String? category;
  final String color;
  final String? hex;

  /// Second fabric color of patterned items, e.g. the white of navy stripes.
  final String? secondaryColor;
  final String? secondaryHex;
  final String? pattern;
  final String? style;
  final String? season;
  final double? confidence;
  final List<double>? embedding;

  ClothingItemModel({
    this.id,
    this.imageUrl,
    this.name = 'Clothing Item',
    required this.type,
    String? category,
    required this.color,
    this.hex,
    this.secondaryColor,
    this.secondaryHex,
    this.pattern,
    this.style,
    this.season,
    this.confidence,
    this.embedding,
  }) : category = WardrobeTaxonomy.isCategory(category)
           ? category
           : WardrobeTaxonomy.categoryForType(type);

  /// Reads wardrobe rows and recommend responses. In a recommend response
  /// `category` is the detailed type and `wardrobeCategory` is the tab.
  factory ClothingItemModel.fromJson(Map<String, dynamic> json) {
    final type =
        (json['type'] ?? json['category'] ?? 'Unknown') as String;
    return ClothingItemModel(
      id: json['id']?.toString(),
      imageUrl: (json['image_path'] ?? json['imageUrl']) as String?,
      name: (json['name'] ?? type) as String,
      type: type,
      category: (json['wardrobeCategory'] ?? json['category']) as String?,
      color: (json['color'] ?? 'Unknown') as String,
      hex: json['hex'] as String?,
      secondaryColor: json['secondary_color'] as String?,
      secondaryHex: json['secondary_hex'] as String?,
      pattern: json['pattern'] as String?,
      style: json['style'] as String?,
      season: json['season'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      embedding: (json['embedding'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'image_path': imageUrl,
      'name': name,
      'category': category,
      'type': type,
      'color': color,
      'hex': hex,
      'secondary_color': secondaryColor,
      'secondary_hex': secondaryHex,
      'pattern': pattern,
      'style': style,
      'season': season,
      'confidence': confidence,
      'embedding': embedding,
    };
  }

  ClothingItemModel copyWith({
    String? id,
    String? imageUrl,
    String? name,
    String? type,
    String? category,
    String? color,
    String? hex,
    String? secondaryColor,
    String? secondaryHex,
    bool clearSecondary = false,
    String? pattern,
    String? style,
    String? season,
    double? confidence,
    List<double>? embedding,
  }) {
    return ClothingItemModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      color: color ?? this.color,
      hex: hex ?? this.hex,
      secondaryColor: clearSecondary
          ? null
          : secondaryColor ?? this.secondaryColor,
      secondaryHex: clearSecondary ? null : secondaryHex ?? this.secondaryHex,
      pattern: pattern ?? this.pattern,
      style: style ?? this.style,
      season: season ?? this.season,
      confidence: confidence ?? this.confidence,
      embedding: embedding ?? this.embedding,
    );
  }
}
