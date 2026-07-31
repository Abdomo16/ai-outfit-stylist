import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/clothing_item_model.dart';
import '../../../../data/repositories/wardrobe_repository.dart';
import 'wardrobe_state.dart';

class WardrobeCubit extends Cubit<WardrobeState> {
  final WardrobeRepository _repository;

  WardrobeCubit(this._repository) : super(WardrobeInitial());

  Future<void> loadWardrobeItems() async {
    emit(WardrobeLoading());
    try {
      final items = await _repository.getClothingItems();
      emit(WardrobeLoaded(items));
    } catch (e) {
      emit(WardrobeError(e.toString()));
    }
  }

  Future<void> addClothingItem(File image) async {
    try {
      if (state is WardrobeLoaded) {
        emit(WardrobeLoading());
      } else {
        emit(WardrobeLoading());
      }

      final newItem = ClothingItemModel(
        imageUrl: image.path,
        name: 'Analyzing item...',
        category: 'Analyzing',
        color: 'Analyzing',
      );

      await _repository.addClothingItem(newItem);

      await loadWardrobeItems();
    } catch (e) {
      emit(WardrobeError(e.toString()));
      await loadWardrobeItems();
    }
  }

  Future<void> updateClothingItem(ClothingItemModel updatedItem) async {
    try {
      emit(WardrobeLoading());
      await _repository.updateClothingItem(updatedItem);

      // Here we just fetch the items again so it looks like it updated
      await loadWardrobeItems();
    } catch (e) {
      emit(WardrobeError(e.toString()));
      await loadWardrobeItems();
    }
  }

  Future<void> deleteClothingItem(String id) async {
    try {
      emit(WardrobeLoading());
      await _repository.deleteClothingItem(id);
      await loadWardrobeItems();
    } catch (e) {
      emit(WardrobeError(e.toString()));
      await loadWardrobeItems();
    }
  }

  Future<void> refreshWardrobe() async {
    await loadWardrobeItems();
  }
}
