import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'welcome_screen.dart';
import '../../../../navigation/main_navigation_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          // Show a blank dark screen or a splash screen while checking auth status
          return const Scaffold(
            backgroundColor: Color(0xFF141020), // App background color
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8A3FFC), // App primary color
              ),
            ),
          );
        } else if (state is Authenticated) {
          return const MainNavigationScreen();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
