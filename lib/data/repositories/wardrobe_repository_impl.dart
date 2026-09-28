import 'dart:io';

import '../models/clothing_item_model.dart';
import 'wardrobe_repository.dart';
import '../datasources/ai_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WardrobeRepositoryImpl implements WardrobeRepository {
  final AIService aiService;
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  WardrobeRepositoryImpl({required this.aiService});

  @override
  Future<List<ClothingItemModel>> getClothingItems() async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      return const [];
    }
    final response = await _supabaseClient
        .from('wardrobe_items')
        .select()
        .eq('user_id', userId);
    return (response as List<dynamic>)
        .map((e) => ClothingItemModel.fromJson(e))
        .toList();
  }

  @override
  Future<ClothingItemModel> getClothingItemById(String id) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    final response = await _supabaseClient
        .from('wardrobe_items')
        .select()
        .eq('id', id)
        .eq('user_id', userId)
        .single();
    return ClothingItemModel.fromJson(response);
  }

  @override
  Future<void> addClothingItem(ClothingItemModel item) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final imagePath = item.imageUrl;
    if (imagePath == null || !File(imagePath).existsSync()) {
      throw Exception('No valid image file provided');
    }

    // The AI backend segments the image, uploads crops to Supabase Storage,
    // and persists each detected item to the wardrobe_items table with user_id.
    await aiService.uploadWardrobeImage(
      File(imagePath),
      userId: userId,
    );
  }

  @override
  Future<void> updateClothingItem(ClothingItemModel item) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    await _supabaseClient
        .from('wardrobe_items')
        .update(item.toJson())
        .eq('id', item.id!)
        .eq('user_id', userId);
  }

  @override
  Future<void> deleteClothingItem(String id) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    await _supabaseClient
        .from('wardrobe_items')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}
