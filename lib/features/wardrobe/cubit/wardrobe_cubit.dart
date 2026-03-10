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
    // T Replace mock data with repository call when backend is ready
    emit(WardrobeLoading());
    try {
      // Temporarily bypass repository and return mock items for UI preview
      List<ClothingItemModel> mockItems = [
        ClothingItemModel(
          id: "1",
          imageUrl:
              "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60", // White Tee
          category: "Shirts",
          color: "White",
          name: "Essential White Tee",
        ),
        ClothingItemModel(
          id: "2",
          imageUrl:
              "https://images.unsplash.com/photo-1542272604-780c96859332?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60", // Blue Jeans
          category: "Pants",
          color: "Indigo",
          name: "Classic Indigo Denim",
        ),
        ClothingItemModel(
          id: "3",
          imageUrl:
              "https://images.unsplash.com/photo-1542291026-7eec264c27ff?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60", // Red Sneakers
          category: "Shoes",
          color: "Red",
          name: "Rush Runners",
        ),
        ClothingItemModel(
          id: "4",
          imageUrl:
              "https://images.unsplash.com/photo-1591047139829-d91aecb6caea?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60", // Trench Coat
          category: "Jackets",
          color: "Beige",
          name: "Autumn Trench Coat",
        ),
        ClothingItemModel(
          id: "5",
          imageUrl:
              "https://images.unsplash.com/photo-1598032895397-b9472444bf93?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60", // Floral Shirt
          category: "Shirts",
          color: "Pattern",
          name: "Floral Vacation Shirt",
        ),
        ClothingItemModel(
          id: "6",
          imageUrl:
              "https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60", // Tailored Trousers
          category: "Pants",
          color: "Black",
          name: "Tailored Trousers",
        ),
      ];

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      emit(WardrobeLoaded(mockItems));
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

      // Temporarily bypass repository and update the state locally
      // (Normally this would await _repository.updateClothingItem(updatedItem) then loadWardrobeItems)

      // We will pretend there's a backend call here:
      await Future.delayed(const Duration(milliseconds: 500));

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
