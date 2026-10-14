import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/clothing_item_model.dart';
import '../cubit/outfit_cubit.dart';
import '../cubit/outfit_state.dart';
import '../widgets/outfit_preview_card.dart';
import '../widgets/regenerate_button.dart';
import '../../saved_outfits/cubit/saved_outfits_cubit.dart';

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

          return PopScope(
            canPop: !isLoading,
            child: Scaffold(
              backgroundColor: pageColor,
              extendBodyBehindAppBar: false,
              appBar: AppBar(
                title: const Text('AI Suggestion'),
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
                                      ? 'Outfit saved!'
                                      : 'Could not save outfit. Please try again.',
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
                        'No outfit generated. Please try again.',
                        style: TextStyle(color: colors.onSurface),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      children: [
                        Text(
                          'Your Curated Look',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _ScorePill(
                            label: outfit.colorScore == null
                                ? 'Your outfit is ready'
                                : '${(outfit.colorScore! * 100).round()}% color match',
                          ),
                        ),
                        if (outfit.reasons.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _ReasonsCard(reasons: outfit.reasons),
                        ],
                        const SizedBox(height: 20),
                        OutfitPreviewCard(outfit: outfit),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text('Pieces', style: theme.textTheme.titleMedium),
                            const Spacer(),
                            Text(
                              '${outfit.items.where((item) => item.id != null).length} items',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pin a piece to keep it, or swap it for another.',
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

    final swatch = _swatch(item.hex);

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
                  item.category,
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
                        _label(item.color),
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
            label: locked ? 'Pinned' : 'Pin',
            icon: locked ? Icons.push_pin : Icons.push_pin_outlined,
            selected: locked,
            enabled: enabled,
            onPressed: onPin,
          ),
          const SizedBox(width: 6),
          _PieceAction(
            label: 'Swap',
            icon: Icons.swap_horiz,
            selected: false,
            enabled: enabled,
            onPressed: onSwap,
          ),
        ],
      ),
    );
  }

  String _label(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  Color? _swatch(String? hex) {
    if (hex == null) return null;
    var value = hex.trim().replaceFirst('#', '');
    if (value.length == 6) value = 'FF$value';
    final parsed = int.tryParse(value, radix: 16);
    if (parsed == null) return null;
    return Color(parsed);
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
