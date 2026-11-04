import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/wardrobe_colors.dart';
import '../../../../data/models/clothing_item_model.dart';
import '../../../../data/models/outfit_model.dart';
import '../../../../data/repositories/wear_log_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../assistant/screens/chat_screen.dart';
import '../cubit/outfit_cubit.dart';
import '../cubit/outfit_state.dart';
import '../utils/context_labels.dart';
import '../utils/outfit_pieces.dart';
import '../widgets/outfit_preview_card.dart';
import '../widgets/piece_sheet.dart';
import '../widgets/regenerate_button.dart';
import '../../plans/reason_text.dart';
import '../../saved_outfits/cubit/saved_outfits_cubit.dart';
import '../../wardrobe/utils/wardrobe_labels.dart';
import '../../wardrobe/widgets/wardrobe_item_image.dart';

class OutfitResultScreen extends StatefulWidget {
  const OutfitResultScreen({super.key});

  @override
  State<OutfitResultScreen> createState() => _OutfitResultScreenState();
}

class _OutfitResultScreenState extends State<OutfitResultScreen> {
  bool _saved = false;
  bool _isSaving = false;
  String? _savedOutfitId;

  Future<void> _save(OutfitModel outfit) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isSaving = true);
    final saved =
        await context.read<SavedOutfitsCubit>().saveOutfit(outfit.toJson());
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _saved = saved;
      _savedOutfitId = saved ? outfit.id : null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved ? l10n.outfitSaved : l10n.couldNotSaveOutfit),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _markWorn(OutfitModel outfit) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await WearLogRepository().saveWorn(outfit, DateTime.now());
      messenger.showSnackBar(SnackBar(content: Text(l10n.wornToday)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.couldNotSaveWear)));
    }
  }

  void _openChat(OutfitModel outfit, [String? message]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(initialMessage: message, currentOutfit: outfit),
      ),
    );
  }

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

          return PopScope(
            canPop: !isLoading,
            child: Scaffold(
              backgroundColor: pageColor,
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
              ),
              bottomNavigationBar: outfit == null
                  ? null
                  : Material(
                      color: pageColor,
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                          child: Row(
                            children: [
                              _BarAction(
                                icon: _saved ? Icons.favorite : Icons.favorite_border,
                                color: _saved ? Colors.redAccent : AppColors.primary,
                                tooltip: l10n.save,
                                onPressed: _saved || _isSaving || isLoading
                                    ? null
                                    : () => _save(outfit),
                              ),
                              const SizedBox(width: 10),
                              _BarAction(
                                icon: Icons.check_circle_outline,
                                color: AppColors.primary,
                                tooltip: l10n.iWoreThis,
                                onPressed: isLoading ? null : () => _markWorn(outfit),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RegenerateButton(
                                  onPressed: cubit.generateOutfit,
                                  isLoading: isLoading,
                                ),
                              ),
                            ],
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
                  : _ResultBody(
                      outfit: outfit,
                      isLoading: isLoading,
                      cubit: cubit,
                      onTweak: (message) => _openChat(outfit, message),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  final OutfitModel outfit;
  final bool isLoading;
  final OutfitCubit cubit;
  final void Function(String? message) onTweak;

  const _ResultBody({
    required this.outfit,
    required this.isLoading,
    required this.cubit,
    required this.onTweak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final pieces = orderedPieces(outfit.items);
    final reasons = localizedReasons(
      l10n,
      outfit,
      weather: cubit.lastWeather,
      season: cubit.lastSeason,
    );
    final contextChips = [
      if (outfit.occasion.isNotEmpty)
        (Icons.event_outlined, ContextLabels.occasion(l10n, outfit.occasion)),
      if (cubit.lastWeather != null)
        (Icons.thermostat_outlined, ContextLabels.weather(l10n, cubit.lastWeather!)),
      if (cubit.lastSeason != null)
        (Icons.eco_outlined, ContextLabels.season(l10n, cubit.lastSeason!)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        OutfitPreviewCard(
          outfit: outfit,
          loading: isLoading,
          onPieceTap: isLoading ? null : (item) => _showPiece(context, item),
          pinnedIds: cubit.lockIds.toSet(),
        ),
        const SizedBox(height: 20),
        Text(l10n.curatedLook, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          pieces.map((item) => WardrobeLabels.type(l10n, item.type)).join(' · '),
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        if (contextChips.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (icon, label) in contextChips)
                _InfoChip(icon: icon, label: label),
            ],
          ),
        ],
        const SizedBox(height: 16),
        _ScoreAndPalette(outfit: outfit, pieces: pieces),
        if (reasons.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ReasonsCard(reasons: reasons),
        ],
        const SizedBox(height: 24),
        _TweakRow(enabled: !isLoading, onTweak: onTweak),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(l10n.pieces, style: theme.textTheme.titleMedium),
            const Spacer(),
            Text(l10n.itemCount(pieces.length), style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(l10n.piecesHint, style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),
        for (final item in pieces)
          _PieceTile(
            item: item,
            locked: cubit.lockIds.contains(item.id),
            enabled: !isLoading,
            onPin: () => cubit.toggleLock(item.id!),
            onSwap: () => cubit.swapPiece(item.id!),
          ),
      ],
    );
  }

  /// A piece tapped on the board: its photo and details, with pin and swap.
  void _showPiece(BuildContext context, ClothingItemModel item) {
    showPieceSheet(
      context,
      item: item,
      locked: cubit.lockIds.contains(item.id),
      onPin: () => cubit.toggleLock(item.id!),
      onSwap: () => cubit.swapPiece(item.id!),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _ScoreAndPalette extends StatelessWidget {
  final OutfitModel outfit;
  final List<ClothingItemModel> pieces;

  const _ScoreAndPalette({required this.outfit, required this.pieces});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final score = outfit.colorScore;
    final swatches = <Color>[
      for (final item in pieces) ...[
        ?WardrobeColors.swatchFor(item.color, item.hex),
        if (item.secondaryColor != null)
          ?WardrobeColors.swatchFor(item.secondaryColor, item.secondaryHex),
      ],
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: score ?? 0,
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  color: AppColors.primary,
                ),
                Center(
                  child: Text(
                    score == null ? '-' : '${(score * 100).round()}%',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score == null
                      ? l10n.outfitReady
                      : l10n.colorMatch((score * 100).round()),
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final swatch in swatches)
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: swatch,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.outline),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonsCard extends StatelessWidget {
  const _ReasonsCard({required this.reasons});

  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textStyle = theme.textTheme.bodyMedium;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(Icons.lightbulb_outline, color: AppColors.primary),
          title: Text(
            AppLocalizations.of(context).whyItWorks,
            style: theme.textTheme.titleSmall,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
      ),
    );
  }

  String _sentence(String reason) {
    final trimmed = reason.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }
}

class _TweakRow extends StatelessWidget {
  final bool enabled;
  final void Function(String? message) onTweak;

  const _TweakRow({required this.enabled, required this.onTweak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final tweaks = [
      (Icons.thermostat, l10n.tweakWarmer),
      (Icons.weekend_outlined, l10n.tweakCasual),
      (Icons.directions_walk, l10n.tweakShoes),
      (Icons.palette_outlined, l10n.tweakColor),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(l10n.tweakTitle, style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (icon, label) in tweaks)
              ActionChip(
                avatar: Icon(icon, size: 16, color: AppColors.primary),
                label: Text(label),
                onPressed: enabled ? () => onTweak(label) : null,
              ),
            ActionChip(
              avatar: const Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: AppColors.white,
              ),
              label: Text(
                l10n.tweakAsk,
                style: const TextStyle(color: AppColors.white),
              ),
              backgroundColor: AppColors.primary,
              side: BorderSide.none,
              onPressed: enabled ? () => onTweak(null) : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _BarAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onPressed;

  const _BarAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(
              icon,
              color: onPressed == null ? color.withValues(alpha: 0.4) : color,
            ),
          ),
        ),
      ),
    );
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
            child: SizedBox(
              width: 72,
              height: 72,
              child: WardrobeItemImage(
                imageUrl: item.imageUrl,
                iconSize: 28,
                memCacheWidth: 220,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.category != null)
                  Text(
                    WardrobeLabels.category(l10n, item.category!).toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                Text(
                  WardrobeLabels.type(l10n, item.type),
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
