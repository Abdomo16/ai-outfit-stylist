import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/auth_repository.dart';
import '../features/auth/cubit/auth_cubit.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(AuthRepository())..checkAuthStatus(),
        ),
      ],
      child: child,
    );
  }
}
