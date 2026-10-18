import 'package:uuid/uuid.dart';
import 'clothing_item_model.dart';

class OutfitModel {
  final String id;
  final String name;
  final String occasion;
  final String stylePreference;
  final ClothingItemModel? top;
  final ClothingItemModel? bottom;
  final ClothingItemModel? shoes;
  final ClothingItemModel? accessories;
  final String explanation;
  final String? imageUrl;
  final double? score;
  final double? colorScore;
  final List<String> reasons;
  final List<ReasonCodeModel> reasonCodes;
  final List<ClothingItemModel> items;

  OutfitModel({
    required this.id,
    required this.name,
    required this.occasion,
    this.stylePreference = 'casual',
    this.top,
    this.bottom,
    this.shoes,
    this.accessories,
    this.explanation = '',
    this.imageUrl,
    this.score,
    this.colorScore,
    this.reasons = const [],
    this.reasonCodes = const [],
    this.items = const [],
  });

  factory OutfitModel.fromJson(
    Map<String, dynamic> json, {
    String? stylePreference,
  }) {
    // Backend returns: {"outfit": [...], "score": 0.91, "occasion": "casual"}
    final List<dynamic> rawItems =
        (json['outfit'] as List<dynamic>?) ??
        (json['items'] as List<dynamic>?) ??
        [];
    final List<ClothingItemModel> parsedItems = rawItems
        .map((v) => ClothingItemModel.fromJson(v as Map<String, dynamic>))
        .toList();

    // Assign items to outfit slots by wardrobe tab. A dress fills the top
    // slot; outerwear only fills it when there is no top or dress.
    ClothingItemModel? firstIn(Set<String> categories) {
      for (final item in parsedItems) {
        if (categories.contains(item.category)) return item;
      }
      return null;
    }

    final top =
        firstIn(const {'Tops', 'Dresses'}) ?? firstIn(const {'Outerwear'});
    final bottom = firstIn(const {'Bottoms'});
    final shoes = firstIn(const {'Shoes'});
    final accessories = firstIn(const {'Accessories', 'Bags'});

    final occasion = (json['occasion'] as String?) ?? 'casual';
    final rawId = json['id'];
    final reasons = (json['reasons'] as List<dynamic>?)
            ?.map((reason) => reason.toString())
            .toList() ??
        const <String>[];
    final reasonCodes = (json['reason_codes'] as List<dynamic>?)
            ?.whereType<Map>()
            .map((code) => ReasonCodeModel.fromJson(Map<String, dynamic>.from(code)))
            .toList() ??
        const <ReasonCodeModel>[];

    return OutfitModel(
      id: rawId is String && rawId.isNotEmpty ? rawId : const Uuid().v4(),
      name: 'AI Generated Outfit',
      occasion: occasion,
      stylePreference:
          stylePreference ?? (json['style'] as String?) ?? occasion,
      explanation: reasons.isNotEmpty
          ? reasons.join('\n')
          : 'A curated outfit for $occasion.',
      score: (json['score'] as num?)?.toDouble(),
      colorScore: (json['color_score'] as num?)?.toDouble(),
      reasons: reasons,
      reasonCodes: reasonCodes,
      items: parsedItems,
      top: top,
      bottom: bottom,
      shoes: shoes,
      accessories: accessories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'occasion': occasion,
      'stylePreference': stylePreference,
      'explanation': explanation,
      'score': score,
      'color_score': colorScore,
      'reasons': reasons,
      'reason_codes': reasonCodes.map((code) => code.toJson()).toList(),
      'imageUrl': imageUrl,
      'items': items.map((i) => i.toJson()).toList(),
      'outfit': items.map((i) => i.toJson()).toList(),
    };
  }
}

class ReasonCodeModel {
  final String code;
  final List<String> colors;

  const ReasonCodeModel({required this.code, this.colors = const []});

  factory ReasonCodeModel.fromJson(Map<String, dynamic> json) {
    return ReasonCodeModel(
      code: json['code']?.toString() ?? '',
      colors: (json['colors'] as List<dynamic>?)
              ?.map((color) => color.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {'code': code, 'colors': colors};
}
