import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onEdit;

  const ProfileAvatar({super.key, this.imageUrl, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.tertiary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: colors.surface,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null
                ? Icon(
                    Icons.person,
                    size: 50,
                    color: colors.onSurfaceVariant,
                  )
                : null,
          ),
        ),
        if (onEdit != null)
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 3),
              ),
              child: Icon(
                Icons.edit,
                color: colors.onPrimary,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }
}
