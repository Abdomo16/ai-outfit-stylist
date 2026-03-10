import 'outfit_model.dart';

class ShareOutfitModel {
  final String id;
  final OutfitModel outfit;
  final String sharedByUserId;
  final DateTime sharedAt;
  final String? message;

  ShareOutfitModel({
    required this.id,
    required this.outfit,
    required this.sharedByUserId,
    required this.sharedAt,
    this.message,
  });
}
