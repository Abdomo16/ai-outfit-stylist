import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../assistant/screens/chat_screen.dart';
import '../../plans/screens/trip_plan_screen.dart';
import '../../plans/screens/week_plan_screen.dart';
import '../cubit/outfit_cubit.dart';
import '../cubit/outfit_state.dart';
import '../widgets/ask_ai_bar.dart';
import '../widgets/quick_action_tile.dart';
import '../widgets/styling_progress.dart';
import 'outfit_result_screen.dart';
import '../../../../data/repositories/wardrobe_repository_impl.dart';
import '../../../../data/datasources/ai_service.dart';

class OutfitGeneratorScreen extends StatelessWidget {
  final VoidCallback? onExit;

  const OutfitGeneratorScreen({super.key, this.onExit});

  @override
  Widget build(BuildContext context) {
    final aiService = AIService();
    final wardrobeRepo = WardrobeRepositoryImpl(aiService: aiService);

    return BlocProvider(
      create: (context) => OutfitCubit(wardrobeRepo, aiService),
      child: _GeneratorView(onExit: onExit),
    );
  }
}

class _GeneratorView extends StatelessWidget {
  final VoidCallback? onExit;

  const _GeneratorView({this.onExit});

  void _openChat(BuildContext context, String message) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(initialMessage: message)),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createYourLook),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: onExit ?? () => Navigator.of(context).maybePop(),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: BlocConsumer<OutfitCubit, OutfitState>(
        listener: (context, state) {
          if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
          if (state is OutfitGenerated) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<OutfitCubit>(),
                  child: const OutfitResultScreen(),
                ),
              ),
            );
          } else if (state is OutfitError) {
            final needsLocation = state.message.contains('location');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                action: needsLocation
                    ? SnackBarAction(
                        label: l10n.allowLocationButton,
                        textColor: AppColors.white,
                        onPressed: Geolocator.openAppSettings,
                      )
                    : null,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<OutfitCubit>();
          final isLoading = state is OutfitLoading;

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                          children: [
                            AskAiBar(
                              onSend: (message) => _openChat(context, message),
                              selectedOccasion: cubit.selectedOccasion,
                              onSelectOccasion: cubit.selectOccasion,
                            ),
                            if (isLoading) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.medium,
                                  ),
                                  border: Border.all(color: colors.outline),
                                ),
                                child: const Center(child: StylingProgress()),
                              ),
                            ],
                            const SizedBox(height: 28),
                            Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(
                                      alpha: 0.10,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.small,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.event_note_rounded,
                                    color: colors.primary,
                                    size: 17,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  l10n.quickPicks,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final tileWidth =
                                    (constraints.maxWidth - 12) / 2;
                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    SizedBox(
                                      width: tileWidth,
                                      child: QuickActionTile(
                                        icon: Icons.calendar_view_week_rounded,
                                        color: AppColors.primary,
                                        title: l10n.thisWeek,
                                        subtitle: l10n.thisWeekHint,
                                        onTap: () => _push(
                                          context,
                                          const WeekPlanScreen(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: tileWidth,
                                      child: QuickActionTile(
                                        icon: Icons.luggage_outlined,
                                        color: AppColors.success,
                                        title: l10n.planTrip,
                                        subtitle: l10n.planTripHint,
                                        onTap: () => _push(
                                          context,
                                          const TripPlanScreen(),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed:
                                isLoading || cubit.selectedOccasion == null
                                ? null
                                : cubit.generateOutfit,
                            icon: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 20,
                            ),
                            label: Text(l10n.generate),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
