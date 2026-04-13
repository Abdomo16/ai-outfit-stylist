import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
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

  Future<void> addClothingItem(
    File image,
    String category,
    String color,
  ) async {
    try {
      // Show loading while keeping previous items if possible
      if (state is WardrobeLoaded) {
        emit(WardrobeLoading());
      } else {
        emit(WardrobeLoading());
      }

      // We will assume StorageService & repository upload handles image internally
      // and returns the image URL. Here, we'll create the model to pass to the repo.
      final newItem = ClothingItemModel(
        id: const Uuid().v4(),
        imageUrl: image.path, // Temporary, repo handles upload
        name: '$color $category',
        category: category,
        color: color,
      );

      await _repository.addClothingItem(newItem);

      // Refresh the items after adding
      await loadWardrobeItems();
    } catch (e) {
      emit(WardrobeError(e.toString()));
      // Optionally reload items so the UI isn't stuck on error
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
