import 'package:equatable/equatable.dart';
import '../../../../data/models/clothing_item_model.dart';

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

  const WardrobeLoaded(
    this.items, {
    this.analyzingCurrent = 0,
    this.analyzingTotal = 0,
  });

  bool get isAnalyzing => analyzingTotal > 0;

  WardrobeLoaded copyWith({
    List<ClothingItemModel>? items,
    int? analyzingCurrent,
    int? analyzingTotal,
  }) {
    return WardrobeLoaded(
      items ?? this.items,
      analyzingCurrent: analyzingCurrent ?? this.analyzingCurrent,
      analyzingTotal: analyzingTotal ?? this.analyzingTotal,
    );
  }

  @override
  List<Object?> get props => [items, analyzingCurrent, analyzingTotal];
}

class WardrobeError extends WardrobeState {
  final String message;

  const WardrobeError(this.message);

  @override
  List<Object?> get props => [message];
}
