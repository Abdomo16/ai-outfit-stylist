import 'package:equatable/equatable.dart';
import '../../../../data/models/clothing_item_model.dart';
import '../../../../data/models/pending_wardrobe_item.dart';

abstract class WardrobeState extends Equatable {
  const WardrobeState();

  @override
  List<Object?> get props => [];
}

class WardrobeInitial extends WardrobeState {}

class WardrobeLoading extends WardrobeState {}

class WardrobeLoaded extends WardrobeState {
  final List<ClothingItemModel> items;
  final int analyzingCurrent;
  final int analyzingTotal;

  /// Partly visible items from finished uploads, waiting for keep or skip.
  final List<PendingWardrobeItem> pending;

  const WardrobeLoaded(
    this.items, {
    this.analyzingCurrent = 0,
    this.analyzingTotal = 0,
    this.pending = const [],
  });

  bool get isAnalyzing => analyzingTotal > 0;

  WardrobeLoaded copyWith({
    List<ClothingItemModel>? items,
    int? analyzingCurrent,
    int? analyzingTotal,
    List<PendingWardrobeItem>? pending,
  }) {
    return WardrobeLoaded(
      items ?? this.items,
      analyzingCurrent: analyzingCurrent ?? this.analyzingCurrent,
      analyzingTotal: analyzingTotal ?? this.analyzingTotal,
      pending: pending ?? this.pending,
    );
  }

  @override
  List<Object?> get props => [items, analyzingCurrent, analyzingTotal, pending];
}

class WardrobeError extends WardrobeState {
  final String message;

  const WardrobeError(this.message);

  @override
  List<Object?> get props => [message];
}
