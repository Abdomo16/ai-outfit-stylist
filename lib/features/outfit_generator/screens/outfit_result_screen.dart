import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/wardrobe_colors.dart';
import '../../../../data/models/clothing_item_model.dart';
import '../../../../data/repositories/wear_log_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/outfit_cubit.dart';
import '../cubit/outfit_state.dart';
import '../widgets/outfit_preview_card.dart';
import '../widgets/regenerate_button.dart';
import '../../plans/reason_text.dart';
import '../../saved_outfits/cubit/saved_outfits_cubit.dart';
import '../../wardrobe/utils/wardrobe_labels.dart';

class OutfitResultScreen extends StatefulWidget {
  const OutfitResultScreen({super.key});

  @override
  State<OutfitResultScreen> createState() => _OutfitResultScreenState();
}

class _OutfitResultScreenState extends State<OutfitResultScreen> {
  bool _saved = false;
  bool _isSaving = false;
  String? _savedOutfitId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocListener<OutfitCubit, OutfitState>(
      listener: (context, state) {
        if (state is OutfitError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
        if (state is OutfitGenerated &&
            _saved &&
            state.outfit.id != _savedOutfitId) {
          setState(() {
            _saved = false;
            _savedOutfitId = null;
          });
        }
      },
      child: BlocBuilder<OutfitCubit, OutfitState>(
        builder: (context, state) {
          final isLoading = state is OutfitLoading;
          final outfit = switch (state) {
            OutfitGenerated(:final outfit) => outfit,
            OutfitLoading(:final previousOutfit) => previousOutfit,
            OutfitError(:final previousOutfit) => previousOutfit,
            _ => null,
          };

          final theme = Theme.of(context);
          final pageColor = theme.scaffoldBackgroundColor;
          final l10n = AppLocalizations.of(context);
          final cubit = context.read<OutfitCubit>();
          final reasons = outfit == null
              ? const <String>[]
              : localizedReasons(
                  l10n,
                  outfit,
                  weather: cubit.lastWeather,
                  season: cubit.lastSeason,
                  style: cubit.selectedStyle,
                );

          return PopScope(
            canPop: !isLoading,
            child: Scaffold(
              backgroundColor: pageColor,
              extendBodyBehindAppBar: false,
              appBar: AppBar(
                title: Text(l10n.aiSuggestion),
                centerTitle: true,
                backgroundColor: pageColor,
                surfaceTintColor: Colors.transparent,
                scrolledUnderElevation: 0,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _saved ? Icons.favorite : Icons.favorite_border,
                      color: _saved ? Colors.redAccent : AppColors.primary,
                    ),
                    onPressed: _saved || _isSaving || outfit == null || isLoading
                        ? null
                        : () async {
                            setState(() => _isSaving = true);
                            final saved = await context
                                .read<SavedOutfitsCubit>()
                                .saveOutfit(outfit.toJson());
                            if (!context.mounted) return;

                            setState(() {
                              _isSaving = false;
                              _saved = saved;
                              _savedOutfitId = saved ? outfit.id : null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                      saved
                                          ? l10n.outfitSaved
                                          : l10n.couldNotSaveOutfit,
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                  ),
                ],
              ),
              bottomNavigationBar: outfit == null
                  ? null
                  : Material(
                      color: pageColor,
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                          child: RegenerateButton(
                            onPressed: () =>
                                context.read<OutfitCubit>().generateOutfit(),
                            isLoading: isLoading,
                          ),
                        ),
                      ),
                    ),
              body: outfit == null
                  ? Center(
                      child: Text(
                        l10n.noOutfitGenerated,
                        style: TextStyle(color: colors.onSurface),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      children: [
                        Text(
                          l10n.curatedLook,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _ScorePill(
                            label: outfit.colorScore == null
                                ? l10n.outfitReady
                                : l10n.colorMatch((outfit.colorScore! * 100).round()),
                          ),
                        ),
                        if (reasons.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _ReasonsCard(reasons: reasons),
                        ],
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  try {
                                    await WearLogRepository().saveWorn(
                                      outfit,
                                      DateTime.now(),
                                    );
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(l10n.wornToday)),
                                    );
                                  } catch (_) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(l10n.couldNotSaveWear)),
                                    );
                                  }
                                },
                          child: Text(l10n.iWoreThis),
                        ),
                        const SizedBox(height: 20),
                        OutfitPreviewCard(outfit: outfit),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(l10n.pieces, style: theme.textTheme.titleMedium),
                            const Spacer(),
                            Text(
                              l10n.itemCount(
                                outfit.items.where((item) => item.id != null).length,
                              ),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.piecesHint,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        for (final item in outfit.items)
                          if (item.id != null)
                            _PieceTile(
                              item: item,
                              locked: context
                                  .read<OutfitCubit>()
                                  .lockIds
                                  .contains(item.id),
                              enabled: !isLoading,
                              onPin: () => context
                                  .read<OutfitCubit>()
                                  .toggleLock(item.id!),
                              onSwap: () =>
                                  context.read<OutfitCubit>().swapPiece(item.id!),
                            ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _ReasonsCard extends StatelessWidget {
  const _ReasonsCard({required this.reasons});

  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < reasons.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.check, size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(_sentence(reasons[i]), style: textStyle)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _sentence(String reason) {
    final trimmed = reason.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }
}

class _PieceTile extends StatelessWidget {
  const _PieceTile({
    required this.item,
    required this.locked,
    required this.enabled,
    required this.onPin,
    required this.onSwap,
  });

  final ClothingItemModel item;
  final bool locked;
  final bool enabled;
  final VoidCallback onPin;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final swatch = WardrobeColors.swatchFor(item.color, item.hex);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: locked ? AppColors.primary : colors.outline,
          width: locked ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: ColoredBox(
              color: colors.surfaceContainerHighest,
              child: SizedBox(
                width: 72,
                height: 72,
                child: _thumb(item.imageUrl),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WardrobeLabels.type(AppLocalizations.of(context), item.type),
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (swatch != null) ...[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: swatch,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.outline),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        WardrobeLabels.colors(l10n, item),
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _PieceAction(
            label: locked ? l10n.pinned : l10n.pin,
            icon: locked ? Icons.push_pin : Icons.push_pin_outlined,
            selected: locked,
            enabled: enabled,
            onPressed: onPin,
          ),
          const SizedBox(width: 6),
          _PieceAction(
            label: l10n.swap,
            icon: Icons.swap_horiz,
            selected: false,
            enabled: enabled,
            onPressed: onSwap,
          ),
        ],
      ),
    );
  }

  Widget _thumb(String? url) {
    if (url == null || url.isEmpty) {
      return const Icon(Icons.checkroom, color: AppColors.primary);
    }
    if (url.startsWith('http')) {
      return Image.network(url, fit: BoxFit.contain);
    }
    if (File(url).existsSync()) {
      return Image.file(File(url), fit: BoxFit.contain);
    }
    return const Icon(Icons.checkroom, color: AppColors.primary);
  }
}

class _PieceAction extends StatelessWidget {
  const _PieceAction({
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.white : AppColors.primary;
    final background = selected
        ? AppColors.primary
        : AppColors.primary.withValues(alpha: 0.1);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 52,
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: enabled ? foreground : foreground.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: enabled ? foreground : foreground.withValues(alpha: 0.4),
                  letterSpacing: 0,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
