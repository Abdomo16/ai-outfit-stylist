class ClothingItemModel {
  final String? id;
  final String? imageUrl;
  final String name;
  final String category;
  final String color;
  final String? hex;
  final String? pattern;
  final String? style;
  final String? season;
  final double? confidence;
  final List<double>? embedding;

  ClothingItemModel({
    this.id,
    this.imageUrl,
    this.name = 'Clothing Item',
    required this.category,
    required this.color,
    this.hex,
    this.pattern,
    this.style,
    this.season,
    this.confidence,
    this.embedding,
  });

  factory ClothingItemModel.fromJson(Map<String, dynamic> json) {
    return ClothingItemModel(
      id: json['id']?.toString(),
      imageUrl: (json['image_path'] ?? json['imageUrl']) as String?,
      name:
          (json['name'] ?? json['type'] ?? json['category'] ?? 'Clothing Item')
              as String,
      category: (json['type'] ?? json['category'] ?? 'Unknown') as String,
      color: (json['color'] ?? 'Unknown') as String,
      hex: json['hex'] as String?,
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
      'type': category,
      'color': color,
      'hex': hex,
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
    String? category,
    String? color,
    String? hex,
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
      category: category ?? this.category,
      color: color ?? this.color,
      hex: hex ?? this.hex,
      pattern: pattern ?? this.pattern,
      style: style ?? this.style,
      season: season ?? this.season,
      confidence: confidence ?? this.confidence,
      embedding: embedding ?? this.embedding,
    );
  }
}
