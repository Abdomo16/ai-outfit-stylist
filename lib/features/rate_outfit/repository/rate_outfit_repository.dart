import 'dart:io';
import '../../../core/services/ai_service.dart';
import '../models/rate_outfit_result_model.dart';

class RateOutfitRepository {
  final AIService _aiService;

  RateOutfitRepository({AIService? aiService}) 
      : _aiService = aiService ?? AIService();

  Future<RateOutfitResultModel> rateOutfit(File image) async {
    try {
      return await _aiService.analyzeOutfitImage(image);
    } catch (e) {
      throw Exception('Failed to rate outfit: $e');
    }
  }
}
