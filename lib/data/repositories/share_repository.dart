import '../models/share_outfit_model.dart';
import '../models/outfit_model.dart';

abstract class ShareRepository {
  Future<String> generateShareLink(OutfitModel outfit);
  Future<void> shareToSocialMedia(OutfitModel outfit);
  Future<ShareOutfitModel> getSharedOutfit(String shareId);
}
