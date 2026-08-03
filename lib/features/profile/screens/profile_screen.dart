import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../navigation/route_names.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../repository/profile_repository.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/logout_button.dart';
import '../widgets/delete_account_dialog.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.card,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
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
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 32, top: 16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: ProfileHeader(
                            profile: state.profile,
                            onEditAvatar: () => _pickImage(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Security',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            const LogoutButton(),
                            const SizedBox(height: 12),
                            ProfileMenuItem(
                              icon: Icons.person_remove_rounded,
                              title: 'Delete Account',
                              iconColor: AppColors.error,
                              textColor: AppColors.error,
                              iconBackgroundColor: AppColors.error.withOpacity(
                                0.15,
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const DeleteAccountDialog(),
                                );
                              },
                            ),
                            const SizedBox(height: 48),
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
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
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
