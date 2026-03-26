import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/profile_model.dart';
import 'profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback? onEditAvatar;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.onEditAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileAvatar(
          imageUrl: profile.avatarUrl,
          onEdit: onEditAvatar,
        ),
        const SizedBox(height: 16),
        Text(
          profile.name,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 22,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        if (profile.isPremium)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(38),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'PREMIUM MEMBER',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }
}
