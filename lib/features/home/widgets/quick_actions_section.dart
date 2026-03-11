import 'package:flutter/material.dart';
import 'action_card.dart';

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
              onTap: () {},
            ),
            ActionCard(
              icon: Icons.analytics,
              title: 'Outfit Analysis',
              subtitle: 'Check style score',
              onTap: () {},
            ),
            ActionCard(
              icon: Icons.share,
              title: 'Share Style',
              subtitle: 'Community trends',
              onTap: () {},
            ),
            ActionCard(
              icon: Icons.quiz,
              title: 'Style Quiz',
              subtitle: 'Refine your AI',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}
