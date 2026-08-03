import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit({required ProfileRepository repository})
    : _repository = repository,
      super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final profile = await _repository.getUserProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(ProfileLoading());
    try {
      await _repository.logout();
      emit(ProfileUnauthenticated());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> deleteAccount() async {
    emit(ProfileLoading());
    try {
      await _repository.deleteAccount();
      emit(ProfileUnauthenticated());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> uploadAvatar(String imagePath) async {
    emit(ProfileLoading());
    try {
      await _repository.uploadAvatar(imagePath);
      await loadProfile();
    } catch (e) {
      emit(ProfileError(e.toString()));
      await loadProfile();
    }
  }
}
