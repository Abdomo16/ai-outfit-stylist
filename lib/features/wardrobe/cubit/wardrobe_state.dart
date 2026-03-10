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

  const WardrobeLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class WardrobeError extends WardrobeState {
  final String message;

  const WardrobeError(this.message);

  @override
  List<Object?> get props => [message];
}
