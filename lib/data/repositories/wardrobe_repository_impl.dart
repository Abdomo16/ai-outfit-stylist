import 'dart:io';
import '../models/clothing_item_model.dart';
import 'wardrobe_repository.dart';
import '../datasources/ai_service.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WardrobeRepositoryImpl implements WardrobeRepository {
  final AIService aiService;
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  WardrobeRepositoryImpl({required this.aiService});

  @override
  Future<List<ClothingItemModel>> getClothingItems() async {
    final response = await _supabaseClient.from('wardrobe_items').select();
    return (response as List<dynamic>)
        .map((e) => ClothingItemModel.fromJson(e))
        .toList();
  }

  @override
  Future<ClothingItemModel> getClothingItemById(String id) async {
    final response = await _supabaseClient
        .from('wardrobe_items')
        .select()
        .eq('id', id)
        .single();
    return ClothingItemModel.fromJson(response);
  }

  @override
  Future<void> addClothingItem(ClothingItemModel item) async {
    ClothingItemModel itemToAdd = item;

    // Check if there is an image to upload to AI backend
    if (item.imageUrl != null && File(item.imageUrl!).existsSync()) {
      final file = File(item.imageUrl!);

      // 1. Upload the original image to Supabase Storage for a permanent public URL
      final fileExt = file.path.split('.').last;
      final storagePath = 'wardrobe/${const Uuid().v4()}.$fileExt';
      await _supabaseClient.storage
          .from('wardrobe-images')
          .upload(storagePath, file);
      final publicUrl = _supabaseClient.storage
          .from('wardrobe-images')
          .getPublicUrl(storagePath);

      // 2. Send to AI backend for item extraction
      final extractedItems = await aiService.uploadWardrobeImage(file);

      // 3. Save all extracted items to Supabase with the public image URL
      final newItems = extractedItems.map((e) {
        final id = const Uuid().v4();
        // Always use the public Supabase URL so both the app and backend can access it
        return e.copyWith(id: id, imageUrl: publicUrl).toJson();
      }).toList();

      if (newItems.isNotEmpty) {
        await _supabaseClient.from('wardrobe_items').insert(newItems);
      }
      return;
    }

    // Fallback if no valid file
    if (itemToAdd.id == null) {
      itemToAdd = itemToAdd.copyWith(id: const Uuid().v4());
    }
    await _supabaseClient.from('wardrobe_items').insert(itemToAdd.toJson());
  }

  @override
  Future<void> updateClothingItem(ClothingItemModel item) async {
    await _supabaseClient
        .from('wardrobe_items')
        .update(item.toJson())
        .eq('id', item.id!);
  }

  @override
  Future<void> deleteClothingItem(String id) async {
    await _supabaseClient.from('wardrobe_items').delete().eq('id', id);
  }
}
