import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../saved_outfits/widgets/saved_outfit_card.dart';
import '../../saved_outfits/cubit/saved_outfits_cubit.dart';
import '../../saved_outfits/cubit/saved_outfits_state.dart';
import '../../saved_outfits/screens/saved_outfit_detail_screen.dart';
import '../../saved_outfits/screens/saved_outfits_screen.dart';

class SavedOutfitsSection extends StatelessWidget {
  const SavedOutfitsSection({super.key});

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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedOutfitsScreen(),
                  ),
                );
              },
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
              if (state.savedOutfits.isEmpty) {
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

              return SizedBox(
                height: 220,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: state.savedOutfits.map((outfitData) {
                      final outfit = outfitData as Map<String, dynamic>;
                      return SizedBox(
                        width: 160,
                        height: 220,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: SavedOutfitCard(
                            outfit: outfit,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SavedOutfitDetailScreen(outfit: outfit),
                                ),
                              );
                            },
                            onDelete: () {
                              context.read<SavedOutfitsCubit>().deleteOutfit(
                                outfit['id'].toString(),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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
