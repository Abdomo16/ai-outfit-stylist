import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onEdit;

  const ProfileAvatar({super.key, this.imageUrl, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF5E17EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.background,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null
                ? const Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.textSecondary,
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
                border: Border.all(color: AppColors.background, width: 3),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 16),
            ),
          ),
      ],
    );
  }
}
