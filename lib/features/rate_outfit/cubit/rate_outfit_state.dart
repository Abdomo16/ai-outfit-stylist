import 'dart:io';
import 'package:equatable/equatable.dart';
import '../models/rate_outfit_result_model.dart';

abstract class RateOutfitState extends Equatable {
  const RateOutfitState();

  @override
  List<Object?> get props => [];
}

class RateOutfitInitial extends RateOutfitState {}

class RateOutfitImageSelected extends RateOutfitState {
  final File image;

  const RateOutfitImageSelected(this.image);

  @override
  List<Object?> get props => [image];
}

class RateOutfitLoading extends RateOutfitState {
  final File image;

  const RateOutfitLoading(this.image);

  @override
  List<Object?> get props => [image];
}

class RateOutfitSuccess extends RateOutfitState {
  final File image;
  final RateOutfitResultModel result;

  const RateOutfitSuccess(this.image, this.result);

  @override
  List<Object?> get props => [image, result];
}

class RateOutfitError extends RateOutfitState {
  final String message;
  final File? image;

  const RateOutfitError(this.message, {this.image});

  @override
  List<Object?> get props => [message, image];
}
