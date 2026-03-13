import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StyleSelector extends StatelessWidget {
  final String? selectedStyle;
  final Function(String) onSelect;

  const StyleSelector({
    super.key,
    required this.selectedStyle,
    required this.onSelect,
  });

  final List<Map<String, String>> styles = const [
    {'name': 'Streetwear', 'image': 'assets/images/styles/streetwear.png'},
    {'name': 'Elegant', 'image': 'assets/images/styles/elegant.png'},
    {'name': 'Minimal', 'image': 'assets/images/styles/minimal.png'},
    {'name': 'Vintage', 'image': 'assets/images/styles/vintage.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pick your style preference',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose an aesthetic for your outfit AI',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: styles.length,
          itemBuilder: (context, index) {
            final style = styles[index];
            final isSelected = selectedStyle == style['name'];

            return GestureDetector(
              onTap: () => onSelect(style['name']!),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        color: AppColors
                            .background, // Or another appropriate color
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              style['image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback if image not found
                                return Container(
                                  color: AppColors.card,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: AppColors.textSecondary,
                                  ),
                                );
                              },
                            ),
                          ),
                          if (isSelected)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: AppColors.textPrimary,
                                  size: 24,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    style['name']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
