import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../config/supabase_config.dart';
import 'saved_outfits_state.dart';

class SavedOutfitsCubit extends Cubit<SavedOutfitsState> {
  final SupabaseClient _supabase = SupabaseConfig.client;

  SavedOutfitsCubit() : super(SavedOutfitsInitial());

  Future<void> fetchSavedOutfits() async {
    emit(SavedOutfitsLoading());
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(const SavedOutfitsError('User not logged in'));
        return;
      }

      final data = await _supabase
          .from('saved_outfits')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      emit(SavedOutfitsLoaded(data));
    } catch (e) {
      emit(SavedOutfitsError(e.toString()));
    }
  }

  Future<bool> saveOutfit(Map<String, dynamic> outfitData) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return false;
      }

      await _supabase.from('saved_outfits').insert({
        'user_id': userId,
        'outfit_data': outfitData,
      });

      // Refetch after saving
      await fetchSavedOutfits();
      return true;
    } catch (e) {
      emit(SavedOutfitsError(e.toString()));
      return false;
    }
  }

  Future<void> deleteOutfit(String id) async {
    // Optimistic update: remove from UI immediately
    if (state is SavedOutfitsLoaded) {
      final current = (state as SavedOutfitsLoaded).savedOutfits;
      final updated = current
          .where((o) => (o as Map<String, dynamic>)['id'].toString() != id)
          .toList();
      emit(SavedOutfitsLoaded(updated));
    }

    try {
      await _supabase.from('saved_outfits').delete().eq('id', id);
    } catch (e) {
      // Revert on failure
      fetchSavedOutfits();
    }
  }
}
