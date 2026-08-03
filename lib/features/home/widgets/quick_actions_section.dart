import 'package:flutter/material.dart';
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
            ActionCard(
              icon: Icons.checkroom,
              title: 'My Wardrobe',
              subtitle: '245 Items',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WardrobeScreen(),
                  ),
                );
              },
            ),
            ActionCard(
              icon: Icons.favorite,
              title: 'Saved Outfits',
              subtitle: 'Your favorite styles',
              onTap: () {
                // Will navigate to SavedOutfitsScreen
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
