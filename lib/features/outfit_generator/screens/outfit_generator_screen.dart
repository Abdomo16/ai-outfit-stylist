import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/outfit_cubit.dart';
import '../cubit/outfit_state.dart';
import '../widgets/occasion_selector.dart';
import '../widgets/style_selector.dart';
import 'outfit_result_screen.dart';
import '../../../../data/repositories/wardrobe_repository_impl.dart';
import '../../../../data/datasources/ai_service.dart';

class OutfitGeneratorScreen extends StatelessWidget {
  final VoidCallback? onExit;

  const OutfitGeneratorScreen({super.key, this.onExit});

  @override
  Widget build(BuildContext context) {
    final aiService = AIService();
    final wardrobeRepo = WardrobeRepositoryImpl(aiService: aiService);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocProvider(
      create: (context) => OutfitCubit(wardrobeRepo, aiService),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Your Look'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colors.onSurface),
            onPressed: onExit ?? () => Navigator.of(context).maybePop(),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
        ),
        body: BlocConsumer<OutfitCubit, OutfitState>(
          listener: (context, state) {
            if (state is OutfitGenerated &&
                (ModalRoute.of(context)?.isCurrent ?? false)) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<OutfitCubit>(),
                    child: const OutfitResultScreen(),
                  ),
                ),
              );
            } else if (state is OutfitError &&
                (ModalRoute.of(context)?.isCurrent ?? false)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<OutfitCubit>();
            final isLoading = state is OutfitLoading;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Outfit Details',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Step 1 of 2',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    OccasionSelector(
                      selectedOccasion: cubit.selectedOccasion,
                      onSelect: (occasion) => cubit.selectOccasion(occasion),
                    ),
                    const SizedBox(height: 32),
                    StyleSelector(
                      selectedStyle: cubit.selectedStyle,
                      onSelect: (style) => cubit.selectStyle(style),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => cubit.generateOutfit(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: colors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colors.onPrimary,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 20),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
