import 'package:equatable/equatable.dart';
import '../../../../data/models/outfit_model.dart';

abstract class OutfitState extends Equatable {
  const OutfitState();

  @override
  List<Object?> get props => [];
}

class OutfitInitial extends OutfitState {
  final String? selectedOccasion;
  final String? selectedStyle;

  const OutfitInitial({this.selectedOccasion, this.selectedStyle});

  @override
  List<Object?> get props => [selectedOccasion, selectedStyle];
}

class OutfitLoading extends OutfitState {
  final OutfitModel? previousOutfit;

  const OutfitLoading({this.previousOutfit});

  @override
  List<Object?> get props => [previousOutfit];
}

class OutfitGenerated extends OutfitState {
  final OutfitModel outfit;

  const OutfitGenerated(this.outfit);

  @override
  List<Object?> get props => [outfit];
}

class OutfitError extends OutfitState {
  final String message;
  final OutfitModel? previousOutfit;

  const OutfitError(this.message, {this.previousOutfit});

  @override
  List<Object?> get props => [message, previousOutfit];
}
