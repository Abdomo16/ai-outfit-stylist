import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/auth_repository.dart';
import '../features/auth/cubit/auth_cubit.dart';
import '../data/repositories/wardrobe_repository_impl.dart';
import '../features/wardrobe/cubit/wardrobe_cubit.dart';
import '../features/saved_outfits/cubit/saved_outfits_cubit.dart';
import '../data/datasources/ai_service.dart';

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
        BlocProvider<WardrobeCubit>(
          create: (context) =>
              WardrobeCubit(WardrobeRepositoryImpl(aiService: AIService())),
        ),
        BlocProvider<SavedOutfitsCubit>(
          create: (context) => SavedOutfitsCubit()..fetchSavedOutfits(),
        ),
      ],
      child: child,
    );
  }
}
