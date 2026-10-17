import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../navigation/route_names.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../repository/profile_repository.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/language_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(repository: ProfileRepository()),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: colors.surface,
          title: Text(
            AppLocalizations.of(dialogContext).deleteAccountTitle,
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            AppLocalizations.of(dialogContext).deleteAccountBody,
            style: TextStyle(color: colors.onSurface, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                AppLocalizations.of(dialogContext).cancel,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<ProfileCubit>().deleteAccount();
              },
              child: Text(
                AppLocalizations.of(dialogContext).delete,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LanguageCard(),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).accountSecurity,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 16),
                const LogoutButton(),
                const SizedBox(height: 12),
                ProfileMenuItem(
                  icon: Icons.person_remove_rounded,
                  title: AppLocalizations.of(context).deleteAccount,
                  iconColor: AppColors.error,
                  textColor: AppColors.error,
                  iconBackgroundColor: AppColors.error.withValues(alpha: 0.15),
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
