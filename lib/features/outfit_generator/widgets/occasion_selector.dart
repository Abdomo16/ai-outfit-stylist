import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class OccasionSelector extends StatelessWidget {
  final String? selectedOccasion;
  final Function(String) onSelect;

  const OccasionSelector({
    super.key,
    required this.selectedOccasion,
    required this.onSelect,
  });

  final List<Map<String, dynamic>> occasions = const [
    {'name': 'University', 'icon': Icons.school},
    {'name': 'Work', 'icon': Icons.work},
    {'name': 'Date Night', 'icon': Icons.favorite},
    {'name': 'Gym', 'icon': Icons.fitness_center},
    {'name': 'Party', 'icon': Icons.celebration},
    {'name': 'Travel', 'icon': Icons.flight},
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.whatsTheOccasion,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.selectWhere,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: occasions.map((occasion) {
            final isSelected = selectedOccasion == occasion['name'];
            return GestureDetector(
              onTap: () => onSelect(occasion['name'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      occasion['icon'] as IconData,
                      size: 18,
                      color: isSelected
                          ? colors.onPrimary
                          : colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _occasionLabel(l10n, occasion['name'] as String),
                      style: TextStyle(
                        color: isSelected
                            ? colors.onPrimary
                            : colors.onSurfaceVariant,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

String _occasionLabel(AppLocalizations l10n, String name) {
  return switch (name) {
    'University' => l10n.occasionUniversity,
    'Work' => l10n.occasionWork,
    'Date Night' => l10n.occasionDateNight,
    'Gym' => l10n.occasionGym,
    'Party' => l10n.occasionParty,
    'Travel' => l10n.occasionTravel,
    _ => name,
  };
}
