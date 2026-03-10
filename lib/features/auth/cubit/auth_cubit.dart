import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../../../../data/repositories/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(email, password);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> register(String username, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signUp(username, email, password);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
