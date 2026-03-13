import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s the occasion?',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Select where you\'re headed today',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
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
                  color: isSelected ? AppColors.primary : AppColors.card,
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
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      occasion['name'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
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
