import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/locale/locale_cubit.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class LanguageCard extends StatelessWidget {
  const LanguageCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.language, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  _choice(context, const Locale('en'), l10n.english, locale),
                  const SizedBox(width: 8),
                  _choice(context, const Locale('ar'), l10n.arabic, locale),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _choice(BuildContext context, Locale locale, String label, Locale selected) {
    final active = selected.languageCode == locale.languageCode;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => context.read<LocaleCubit>().setLocale(locale),
        style: OutlinedButton.styleFrom(
          backgroundColor: active ? AppColors.primary : null,
          foregroundColor: active ? AppColors.white : AppColors.primary,
        ),
        child: Text(label),
      ),
    );
  }
}
