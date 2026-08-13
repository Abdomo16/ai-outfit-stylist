import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final items = [
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.checkroom_outlined, Icons.checkroom_rounded, 'Wardrobe'),
      (Icons.auto_awesome_outlined, Icons.auto_awesome, 'Generate'),
      (Icons.favorite_border_rounded, Icons.favorite_rounded, 'Saved'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      height: 73,
      decoration: BoxDecoration(
        // Blend with the app background instead of using surface directly.
        color: Color.alphaBlend(
          colors.primary.withOpacity(0.035),
          colors.surface,
        ),
        borderRadius: BorderRadius.circular(22),

        // Almost invisible border.
        border: Border.all(color: colors.onSurface.withOpacity(0.06), width: 1),

        // Neutral shadow only.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 12,
            offset: const Offset(0, 5),
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
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
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
                    ? colors.primary
                    : colors.onSurfaceVariant.withOpacity(0.65),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? colors.primary
                    : colors.onSurfaceVariant.withOpacity(0.65),
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
                color: selected
                    ? colors.primary
                    : colors.primary.withOpacity(0.85),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 24,
                color: colors.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            'Generate',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? colors.primary
                  : colors.onSurfaceVariant.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }
}
