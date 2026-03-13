import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/outfit_cubit.dart';
import '../cubit/outfit_state.dart';
import '../widgets/outfit_preview_card.dart';
import '../widgets/regenerate_button.dart';

class OutfitResultScreen extends StatelessWidget {
  const OutfitResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Suggestion',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.primary,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.more_horiz,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<OutfitCubit, OutfitState>(
        builder: (context, state) {
          if (state is OutfitLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! OutfitGenerated) {
            return const Center(
              child: Text(
                'No outfit generated. Please try again.',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            );
          }

          final outfit = state.outfit;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Curated Look',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Perfectly styled for your ${outfit.occasion.toLowerCase()} day',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  OutfitPreviewCard(outfit: outfit),
                  const SizedBox(height: 48),
                  RegenerateButton(
                    onPressed: () =>
                        context.read<OutfitCubit>().generateOutfit(),
                    isLoading: state is OutfitLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
