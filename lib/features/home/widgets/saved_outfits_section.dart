import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import 'saved_outfit_card.dart';
import '../models/saved_outfit_model.dart';
import '../cubit/saved_outfits_cubit.dart';
import '../cubit/saved_outfits_state.dart';

class SavedOutfitsSection extends StatefulWidget {
  const SavedOutfitsSection({super.key});

  @override
  State<SavedOutfitsSection> createState() => _SavedOutfitsSectionState();
}

class _SavedOutfitsSectionState extends State<SavedOutfitsSection> {
  @override
  void initState() {
    super.initState();
    context.read<SavedOutfitsCubit>().loadSavedOutfits();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saved Outfits',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<SavedOutfitsCubit, SavedOutfitsState>(
          builder: (context, state) {
            if (state is SavedOutfitsLoading) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            
            if (state is SavedOutfitsError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Could not load saved outfits.\\n${state.message}',
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is SavedOutfitsLoaded) {
              if (state.outfits.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No saved outfits yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: state.outfits.map((outfit) {
                    return SavedOutfitCard(
                      imageUrl: outfit.imageUrl,
                      title: outfit.title,
                      savedTime: outfit.savedTime,
                      onTap: () {},
                      onFavoriteTap: () {},
                    );
                  }).toList(),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
