import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/outfit_cubit.dart';
import '../cubit/outfit_state.dart';
import '../widgets/outfit_preview_card.dart';
import '../widgets/regenerate_button.dart';
import '../../saved_outfits/cubit/saved_outfits_cubit.dart';

class OutfitResultScreen extends StatefulWidget {
  const OutfitResultScreen({super.key});

  @override
  State<OutfitResultScreen> createState() => _OutfitResultScreenState();
}

class _OutfitResultScreenState extends State<OutfitResultScreen> {
  bool _saved = false;
  bool _isSaving = false;
  String? _savedOutfitId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<OutfitCubit, OutfitState>(
      listener: (context, state) {
        if (state is OutfitError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
        if (state is OutfitGenerated &&
            _saved &&
            state.outfit.id != _savedOutfitId) {
          setState(() {
            _saved = false;
            _savedOutfitId = null;
          });
        }
      },
      child: BlocBuilder<OutfitCubit, OutfitState>(
        builder: (context, state) {
          final isLoading = state is OutfitLoading;
          final outfit = switch (state) {
            OutfitGenerated(:final outfit) => outfit,
            OutfitLoading(:final previousOutfit) => previousOutfit,
            OutfitError(:final previousOutfit) => previousOutfit,
            _ => null,
          };

          return PopScope(
            canPop: !isLoading,
            child: Scaffold(
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
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
                      onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _saved ? Icons.favorite : Icons.favorite_border,
                          color: _saved ? Colors.redAccent : AppColors.primary,
                          size: 20,
                        ),
                        onPressed: _saved || _isSaving || outfit == null || isLoading
                            ? null
                            : () async {
                                setState(() => _isSaving = true);
                                final saved = await context
                                    .read<SavedOutfitsCubit>()
                                    .saveOutfit(outfit.toJson());
                                if (!context.mounted) return;

                                setState(() {
                                  _isSaving = false;
                                  _saved = saved;
                                  _savedOutfitId = saved ? outfit.id : null;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      saved
                                          ? 'Outfit saved!'
                                          : 'Could not save outfit. Please try again.',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                      ),
                    ),
                  ),
                ],
              ),
              body: outfit == null
                  ? const Center(
                      child: Text(
                        'No outfit generated. Please try again.',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    )
                  : SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
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
                              onPressed: () => context.read<OutfitCubit>().generateOutfit(),
                              isLoading: isLoading,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
