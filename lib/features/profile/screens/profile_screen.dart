import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../navigation/route_names.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../repository/profile_repository.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/logout_button.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/theme_mode_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileCubit(repository: ProfileRepository())..loadProfile(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && context.mounted) {
        context.read<ProfileCubit>().uploadAvatar(image.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is ProfileUnauthenticated) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.login,
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is ProfileLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<ProfileCubit>().loadProfile(),
              color: AppColors.primary,
              backgroundColor: colors.surface,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.xl,
                          top: AppSpacing.md,
                        ),
                        margin: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colors.surface,
                              colors.surfaceContainerHighest,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.large),
                          border: Border.all(color: colors.outline),
                        ),
                        child: Center(
                          child: ProfileHeader(
                            profile: state.profile,
                            onEditAvatar: () => _pickImage(context),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appearance',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const ThemeModeCard(),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Account Security',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const LogoutButton(),
                            const SizedBox(height: AppSpacing.sm),
                            ProfileMenuItem(
                              icon: Icons.person_remove_rounded,
                              title: 'Delete Account',
                              iconColor: AppColors.error,
                              textColor: AppColors.error,
                              iconBackgroundColor: AppColors.error.withValues(
                                alpha: 0.15,
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const DeleteAccountDialog(),
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading profile',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().loadProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
