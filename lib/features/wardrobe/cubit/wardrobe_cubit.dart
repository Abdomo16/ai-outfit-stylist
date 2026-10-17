import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/clothing_item_model.dart';
import '../../../../data/repositories/wardrobe_repository.dart';
import 'wardrobe_state.dart';

class WardrobeCubit extends Cubit<WardrobeState> {
  final WardrobeRepository _repository;

  WardrobeCubit(this._repository) : super(WardrobeInitial());

  List<ClothingItemModel> get _currentItems {
    final s = state;
    if (s is WardrobeLoaded) return s.items;
    return const [];
  }

  Future<void> loadWardrobeItems({bool silent = false}) async {
    if (!silent) {
      emit(WardrobeLoading());
    }
    try {
      final items = await _repository.getClothingItems();
      final analyzing = state is WardrobeLoaded
          ? state as WardrobeLoaded
          : null;
      emit(
        WardrobeLoaded(
          items,
          analyzingCurrent: analyzing?.analyzingCurrent ?? 0,
          analyzingTotal: analyzing?.analyzingTotal ?? 0,
        ),
      );
    } catch (e) {
      emit(WardrobeError(e.toString()));
    }
  }

  Future<void> addClothingItem(File image) async {
    await addClothingItems([image]);
  }

  Future<void> addClothingItems(List<File> images) async {
    if (images.isEmpty) return;

    final total = images.length;
    final existing = _currentItems;

    emit(
      WardrobeLoaded(
        existing,
        analyzingCurrent: 0,
        analyzingTotal: total,
      ),
    );

    var completed = 0;
    var failureCount = 0;

    Future<void> uploadOne(File image) async {
      try {
        await _repository.addClothingItem(
          ClothingItemModel(
            imageUrl: image.path,
            name: 'Analyzing item...',
            category: 'Analyzing',
            color: 'Analyzing',
          ),
        );
      } catch (_) {
        failureCount++;
      } finally {
        completed++;
        if (!isClosed) {
          emit(
            WardrobeLoaded(
              _currentItems,
              analyzingCurrent: completed,
              analyzingTotal: total,
            ),
          );
        }
      }
    }

    await Future.wait(images.map(uploadOne));

    await loadWardrobeItems(silent: true);

    if (!isClosed) {
      final items = state is WardrobeLoaded
          ? (state as WardrobeLoaded).items
          : _currentItems;
      emit(WardrobeLoaded(items));

      if (failureCount > 0) {
        final successCount = total - failureCount;
        emit(WardrobeError('$successCount of $total uploaded'));
        await loadWardrobeItems(silent: true);
      }
    }
  }

  Future<void> updateClothingItem(ClothingItemModel updatedItem) async {
    try {
      emit(WardrobeLoading());
      await _repository.updateClothingItem(updatedItem);
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
    await loadWardrobeItems(silent: true);
  }
}
