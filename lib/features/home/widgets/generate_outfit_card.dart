import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../outfit_generator/screens/outfit_generator_screen.dart';

class GenerateOutfitCard extends StatelessWidget {
  const GenerateOutfitCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1D2A),
            Color(0xFF24283A),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 32,
            spreadRadius: 4,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background accent orb.
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.25),
                    AppColors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Background icon.
          Positioned(
            right: -40,
            bottom: -40,
            child: Icon(
              Icons.auto_awesome,
              size: 220,
              color: AppColors.white.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'PREMIUM AI',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Generate\nYour Outfit',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Discover your perfect look with AI\ntailored to your unique style.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OutfitGeneratorScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.large),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Style Me Now',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.onPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(Icons.auto_awesome, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
