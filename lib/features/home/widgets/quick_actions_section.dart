import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../wardrobe/cubit/wardrobe_cubit.dart';
import '../../wardrobe/cubit/wardrobe_state.dart';
import '../../saved_outfits/cubit/saved_outfits_cubit.dart';
import '../../saved_outfits/cubit/saved_outfits_state.dart';
import 'package:outfit_selctor/features/saved_outfits/screens/saved_outfits_screen.dart';
import 'action_card.dart';
import '../../wardrobe/screens/wardrobe_screen.dart';
import '../screens/share_style_screen.dart';
import '../screens/styling_tips_screen.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            BlocBuilder<WardrobeCubit, WardrobeState>(
              builder: (context, state) {
                String subtitle = 'Loading...';
                if (state is WardrobeLoaded) {
                  subtitle = '${state.items.length} Items';
                } else if (state is WardrobeInitial) {
                  subtitle = '0 Items';
                }
                return ActionCard(
                  icon: Icons.checkroom,
                  title: 'My Wardrobe',
                  subtitle: subtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WardrobeScreen(),
                      ),
                    );
                  },
                );
              },
            ),
            BlocBuilder<SavedOutfitsCubit, SavedOutfitsState>(
              builder: (context, state) {
                String subtitle = 'Loading...';
                if (state is SavedOutfitsLoaded) {
                  subtitle = '${state.savedOutfits.length} Styles';
                } else if (state is SavedOutfitsInitial) {
                  subtitle = '0 Styles';
                }
                return ActionCard(
                  icon: Icons.favorite,
                  title: 'Saved Outfits',
                  subtitle: subtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavedOutfitsScreen(),
                      ),
                    );
                  },
                );
              },
            ),
            ActionCard(
              icon: Icons.share,
              title: 'Share Style',
              subtitle: 'Community trends',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShareStyleScreen(),
                  ),
                );
              },
            ),
            ActionCard(
              icon: Icons.trending_up,
              title: 'Styling Tips',
              subtitle: 'Daily Fashion Advice',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StylingTipsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
