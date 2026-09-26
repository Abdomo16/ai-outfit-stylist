import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final items = [
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.checkroom_outlined, Icons.checkroom_rounded, 'Wardrobe'),
      (Icons.auto_awesome_outlined, Icons.auto_awesome, 'Generate'),
      (Icons.favorite_border_rounded, Icons.favorite_rounded, 'Saved'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: colors.outline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            if (index == 2) {
              return Expanded(
                child: _GenerateItem(
                  selected: currentIndex == index,
                  onTap: () => onTap(index),
                  colors: colors,
                ),
              );
            }

            return Expanded(
              child: _NavItem(
                icon: items[index].$1,
                activeIcon: items[index].$2,
                label: items[index].$3,
                selected: currentIndex == index,
                onTap: () => onTap(index),
                colors: colors,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colors;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                selected ? activeIcon : icon,
                key: ValueKey(selected),
                size: 24,
                color: selected
                    ? AppColors.primary
                    : colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    fontSize: 10.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected
                        ? AppColors.primary
                        : colors.onSurfaceVariant,
                  ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenerateItem extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colors;

  const _GenerateItem({
    required this.selected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: selected ? 1.0 : 0.92,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 24,
                color: colors.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Generate',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? AppColors.primary
                      : colors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
