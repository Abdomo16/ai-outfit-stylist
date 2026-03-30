import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../repository/rate_outfit_repository.dart';
import 'rate_outfit_state.dart';

class RateOutfitCubit extends Cubit<RateOutfitState> {
  final RateOutfitRepository _repository;
  final ImagePicker _picker = ImagePicker();
  
  File? _currentImage;

  RateOutfitCubit({RateOutfitRepository? repository})
      : _repository = repository ?? RateOutfitRepository(),
        super(RateOutfitInitial());

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _currentImage = File(pickedFile.path);
        emit(RateOutfitImageSelected(_currentImage!));
      }
    } catch (e) {
      emit(RateOutfitError('Failed to pick image: $e', image: _currentImage));
    }
  }

  void clearImage() {
    _currentImage = null;
    emit(RateOutfitInitial());
  }

  Future<void> rateOutfit() async {
    if (_currentImage == null) return;

    emit(RateOutfitLoading(_currentImage!));
    try {
      final result = await _repository.rateOutfit(_currentImage!);
      emit(RateOutfitSuccess(_currentImage!, result));
    } catch (e) {
      emit(RateOutfitError(e.toString(), image: _currentImage));
    }
  }
}
