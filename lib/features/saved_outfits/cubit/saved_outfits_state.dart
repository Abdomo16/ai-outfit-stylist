import 'package:equatable/equatable.dart';

abstract class SavedOutfitsState extends Equatable {
  const SavedOutfitsState();

  @override
  List<Object> get props => [];
}

class SavedOutfitsInitial extends SavedOutfitsState {}

class SavedOutfitsLoading extends SavedOutfitsState {}

class SavedOutfitsLoaded extends SavedOutfitsState {
  final List<dynamic> savedOutfits;

  const SavedOutfitsLoaded(this.savedOutfits);

  @override
  List<Object> get props => [savedOutfits];
}

class SavedOutfitsError extends SavedOutfitsState {
  final String message;

  const SavedOutfitsError(this.message);

  @override
  List<Object> get props => [message];
}
