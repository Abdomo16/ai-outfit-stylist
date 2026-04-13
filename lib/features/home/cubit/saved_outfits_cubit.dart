import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/saved_outfits_repository.dart';
import 'saved_outfits_state.dart';

class SavedOutfitsCubit extends Cubit<SavedOutfitsState> {
  final SavedOutfitsRepository _repository;

  SavedOutfitsCubit(this._repository) : super(SavedOutfitsInitial());

  Future<void> loadSavedOutfits() async {
    emit(SavedOutfitsLoading());
    try {
      final outfits = await _repository.getSavedOutfits();
      emit(SavedOutfitsLoaded(outfits));
    } catch (e) {
      emit(SavedOutfitsError(e.toString()));
    }
  }

  Future<void> refreshOutfits() async {
    await loadSavedOutfits();
  }
}
