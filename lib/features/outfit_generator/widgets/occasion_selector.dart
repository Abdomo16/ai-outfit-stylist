import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class OccasionSelector extends StatelessWidget {
  final String? selectedOccasion;
  final ValueChanged<String> onSelect;

  /// Compact chips for embedding inside the stylist card (no page headline).
  final bool embedded;

  const OccasionSelector({
    super.key,
    required this.selectedOccasion,
    required this.onSelect,
    this.embedded = false,
  });

  static const _occasions = [
    ('University', Icons.school_outlined),
    ('Work', Icons.work_outline_rounded),
    ('Date Night', Icons.favorite_border_rounded),
    ('Gym', Icons.fitness_center_rounded),
    ('Party', Icons.celebration_outlined),
    ('Travel', Icons.flight_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final chips = Wrap(
      spacing: embedded ? 8 : 10,
      runSpacing: embedded ? 8 : 10,
      children: [
        for (final (name, icon) in _occasions)
          _OccasionChip(
            label: _occasionLabel(l10n, name),
            icon: icon,
            selected: selectedOccasion == name,
            onTap: () => onSelect(name),
            compact: embedded,
          ),
      ],
    );

    if (embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectWhere,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          chips,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.whatsTheOccasion, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          l10n.selectWhere,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        chips,
      ],
    );
  }
}

class _OccasionChip extends StatelessWidget {
  const _OccasionChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ChoiceChip(
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      avatar: Icon(
        icon,
        size: compact ? 16 : 18,
        color: selected ? colors.onPrimary : colors.onSurfaceVariant,
      ),
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: selected ? colors.onPrimary : colors.onSurface,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        fontSize: compact ? 13 : null,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 6 : 9,
      ),
      side: BorderSide(
        color: selected ? colors.primary : colors.outline,
        width: selected ? 1.5 : 1,
      ),
      selectedColor: colors.primary,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
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
