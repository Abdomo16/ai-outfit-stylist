class ClothingItemModel {
  final String id;
  final String imageUrl;
  final String name;
  final String category; // e.g., Shirts, Pants, Shoes
  final String color;

  ClothingItemModel({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.category,
    required this.color,
  });

  factory ClothingItemModel.fromJson(Map<String, dynamic> json) {
    return ClothingItemModel(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      color: json['color'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'name': name,
      'category': category,
      'color': color,
    };
  }

  ClothingItemModel copyWith({
    String? id,
    String? imageUrl,
    String? name,
    String? category,
    String? color,
  }) {
    return ClothingItemModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
    );
  }
}
