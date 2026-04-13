import 'package:equatable/equatable.dart';
import '../models/saved_outfit_model.dart';

abstract class SavedOutfitsState extends Equatable {
  const SavedOutfitsState();

  @override
  List<Object?> get props => [];
}

class SavedOutfitsInitial extends SavedOutfitsState {}

class SavedOutfitsLoading extends SavedOutfitsState {}

class SavedOutfitsLoaded extends SavedOutfitsState {
  final List<SavedOutfitModel> outfits;

  const SavedOutfitsLoaded(this.outfits);

  @override
  List<Object?> get props => [outfits];
}

class SavedOutfitsError extends SavedOutfitsState {
  final String message;

  const SavedOutfitsError(this.message);

  @override
  List<Object?> get props => [message];
}
