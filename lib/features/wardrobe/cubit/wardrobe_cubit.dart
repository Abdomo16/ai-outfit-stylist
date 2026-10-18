import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/clothing_item_model.dart';
import '../../../../data/models/pending_wardrobe_item.dart';
import '../../../../data/repositories/wardrobe_repository.dart';
import 'wardrobe_state.dart';

class WardrobeCubit extends Cubit<WardrobeState> {
  final WardrobeRepository _repository;

  /// Held-back items from finished uploads. Kept outside the state so an
  /// error state in between does not lose them.
  List<PendingWardrobeItem> _pending = const [];

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
          pending: _pending,
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
        pending: _pending,
      ),
    );

    var completed = 0;
    var failureCount = 0;
    final held = <PendingWardrobeItem>[];

    Future<void> uploadOne(File image) async {
      try {
        held.addAll(
          await _repository.addClothingItem(
            ClothingItemModel(
              imageUrl: image.path,
              name: 'Analyzing item...',
              type: 'Analyzing',
              color: 'Analyzing',
            ),
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
              pending: _pending,
            ),
          );
        }
      }
    }

    await Future.wait(images.map(uploadOne));

    await loadWardrobeItems(silent: true);

    if (!isClosed) {
      _pending = [..._pending, ...held];
      final items = state is WardrobeLoaded
          ? (state as WardrobeLoaded).items
          : _currentItems;
      emit(WardrobeLoaded(items, pending: _pending));

      if (failureCount > 0) {
        final successCount = total - failureCount;
        emit(WardrobeError('$successCount of $total uploaded'));
        await loadWardrobeItems(silent: true);
      }
    }
  }

  /// Saves [keep] out of the [shown] pending items and drops the rest of
  /// [shown]. Pending items that arrived after [shown] stay pending.
  Future<void> keepPending(
    List<PendingWardrobeItem> shown,
    List<PendingWardrobeItem> keep,
  ) async {
    if (shown.isEmpty) return;
    final resolved = shown.toSet();
    _pending = _pending.where((item) => !resolved.contains(item)).toList();
    final s = state;
    if (s is WardrobeLoaded) {
      emit(s.copyWith(pending: _pending));
    }
    try {
      await _repository.keepPendingItems(shown, keep);
    } catch (e) {
      emit(WardrobeError(e.toString()));
    }
    await loadWardrobeItems(silent: true);
  }

  Future<void> skipPending(List<PendingWardrobeItem> shown) =>
      keepPending(shown, const []);

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

  Future<void> deleteClothingItem(String id) => deleteClothingItems([id]);

  /// Removes the items from the grid at once, then deletes them on the
  /// backend. Returns false when the delete failed and the grid was reloaded.
  Future<bool> deleteClothingItems(List<String> ids) async {
    if (ids.isEmpty) return true;
    final s = state;
    if (s is WardrobeLoaded) {
      final remove = ids.toSet();
      emit(s.copyWith(
        items: s.items.where((item) => !remove.contains(item.id)).toList(),
      ));
    }
    try {
      await _repository.deleteClothingItems(ids);
      return true;
    } catch (e) {
      emit(WardrobeError(e.toString()));
      await loadWardrobeItems(silent: true);
      return false;
    }
  }

  Future<void> refreshWardrobe() async {
    await loadWardrobeItems(silent: true);
  }
}
