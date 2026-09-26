import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit({required ProfileRepository repository})
    : _repository = repository,
      super(ProfileInitial());

  void _safeEmit(ProfileState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  Future<void> loadProfile() async {
    _safeEmit(ProfileLoading());
    try {
      final profile = await _repository.getUserProfile();
      _safeEmit(ProfileLoaded(profile));
    } catch (e) {
      _safeEmit(ProfileError(e.toString()));
    }
  }

  Future<void> logout() async {
    _safeEmit(ProfileLoading());
    try {
      await _repository.logout();
      _safeEmit(ProfileUnauthenticated());
    } catch (e) {
      _safeEmit(ProfileError(e.toString()));
    }
  }

  Future<void> deleteAccount() async {
    _safeEmit(ProfileLoading());
    try {
      await _repository.deleteAccount();
      _safeEmit(ProfileUnauthenticated());
    } catch (e) {
      _safeEmit(ProfileError(e.toString()));
    }
  }

  Future<void> uploadAvatar(String imagePath) async {
    _safeEmit(ProfileLoading());
    try {
      await _repository.uploadAvatar(imagePath);
      await loadProfile();
    } catch (e) {
      _safeEmit(ProfileError(e.toString()));
      await loadProfile();
    }
  }
}
