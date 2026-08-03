import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/hero_tip_card.dart';
import '../widgets/styling_tip_card.dart';

class StylingTipsScreen extends StatelessWidget {
  const StylingTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Styling Tips',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const HeroTipCard(),
          const SizedBox(height: 24),
          Text(
            'Daily Fashion Advice',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const StylingTipCard(
            title: 'Mastering the Monochromatic Look',
            description:
                'Stick to one color palette but play with different shades and textures to create a cohesive and sophisticated outfit.',
            icon: Icons.palette,
          ),
          const SizedBox(height: 12),
          const StylingTipCard(
            title: 'The Rule of Thirds',
            description:
                'Avoid cutting your body in half. Aim for a 1/3 to 2/3 ratio for a more flattering and naturally appealing silhouette.',
            icon: Icons.vertical_align_center,
          ),
          const SizedBox(height: 12),
          const StylingTipCard(
            title: 'Accessorize Smartly',
            description:
                'Less is often more. Choose one statement piece—like a bold watch or a chunky necklace—to elevate your entire look.',
            icon: Icons.watch,
          ),
        ],
      ),
    );
  }
}
