import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../config/supabase_config.dart';
import '../models/saved_outfit_model.dart';

class SavedOutfitsRepository {
  final SupabaseClient _supabaseClient;

  SavedOutfitsRepository({SupabaseClient? client})
      : _supabaseClient = client ?? SupabaseConfig.client;

  Future<List<SavedOutfitModel>> getSavedOutfits() async {
    final response = await _supabaseClient
        .from('outfits')
        .select()
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => SavedOutfitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
