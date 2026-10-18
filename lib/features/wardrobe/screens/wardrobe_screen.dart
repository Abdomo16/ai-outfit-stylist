import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/wardrobe_taxonomy.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/pending_wardrobe_item.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/wardrobe_cubit.dart';
import '../cubit/wardrobe_state.dart';
import '../widgets/clothing_card.dart';
import '../widgets/add_clothing_button.dart';
import '../widgets/wardrobe_header.dart';
import '../widgets/category_tabs.dart';
import '../widgets/wardrobe_empty_state.dart';
import '../widgets/analyzing_banner.dart';
import '../widgets/selection_bar.dart';
import '../widgets/delete_bar.dart';
import '../widgets/delete_confirm_sheet.dart';
import '../widgets/partial_items_sheet.dart';
import '../utils/category_utils.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  static const _switchDuration = Duration(milliseconds: 220);

  String _selectedCategory = WardrobeTaxonomy.all;
  final List<String> _categories = [
    WardrobeTaxonomy.all,
    ...WardrobeTaxonomy.categories,
  ];

  /// Ids of selected items. Selection mode is on while this is not empty.
  final Set<String> _selected = {};

  /// Ids shown in the current tab, for "Select all".
  List<String> _visibleIds = const [];

  bool get _selecting => _selected.isNotEmpty;

  @override
  void initState() {
    super.initState();
    context.read<WardrobeCubit>().loadWardrobeItems();
  }

  void _startSelection(String? id) {
    if (id == null) return;
    HapticFeedback.mediumImpact();
    setState(() => _selected.add(id));
  }

  void _toggle(String? id) {
    if (id == null) return;
    HapticFeedback.selectionClick();
    setState(() {
      if (!_selected.remove(id)) _selected.add(id);
    });
  }

  bool get _allVisibleSelected =>
      _visibleIds.isNotEmpty && _visibleIds.every(_selected.contains);

  void _toggleAll() {
    setState(() {
      if (_allVisibleSelected) {
        _selected.removeAll(_visibleIds);
      } else {
        _selected.addAll(_visibleIds);
      }
    });
  }

  void _clearSelection() => setState(_selected.clear);

  bool _pendingSheetOpen = false;

  Future<void> _reviewPending(List<PendingWardrobeItem> pending) async {
    if (_pendingSheetOpen || pending.isEmpty) return;
    _pendingSheetOpen = true;
    final cubit = context.read<WardrobeCubit>();
    final kept = await showPartialItemsSheet(context, pending);
    _pendingSheetOpen = false;
    await cubit.keepPending(pending, kept);
  }

  Future<void> _deleteSelected() async {
    final ids = _selected.toList();
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<WardrobeCubit>();

    final confirmed = await showDeleteConfirmSheet(context, ids.length);
    if (!confirmed || !mounted) return;

    _clearSelection();
    final deleted = await cubit.deleteClothingItems(ids);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(deleted ? l10n.itemsDeleted(ids.length) : l10n.deleteFailed),
        backgroundColor: deleted ? null : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return PopScope(
      canPop: !_selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _clearSelection();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedSwitcher(
                duration: _switchDuration,
                child: _selecting
                    ? SelectionBar(
                        key: const ValueKey('selection'),
                        count: _selected.length,
                        allSelected: _allVisibleSelected,
                        onClose: _clearSelection,
                        onToggleAll: _toggleAll,
                      )
                    : const WardrobeHeader(key: ValueKey('header')),
              ),
              CategoryTabs(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onSelected: (category) {
                  setState(() => _selectedCategory = category);
                },
              ),
              Expanded(
                child: BlocConsumer<WardrobeCubit, WardrobeState>(
                  listener: (context, state) {
                    if (state is WardrobeLoaded && state.pending.isNotEmpty) {
                      _reviewPending(state.pending);
                    }
                    if (state is WardrobeError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.message,
                            style: TextStyle(color: colors.onSurface),
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is WardrobeLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    } else if (state is WardrobeLoaded) {
                      final filteredItems = state.items
                          .where(
                            (item) => CategoryUtils.matchesCategory(
                              item,
                              _selectedCategory,
                            ),
                          )
                          .toList();
                      _visibleIds = [
                        for (final item in filteredItems)
                          if (item.id != null) item.id!,
                      ];

                      return Column(
                        children: [
                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            child: state.isAnalyzing
                                ? AnalyzingBanner(
                                    done: state.analyzingCurrent,
                                    total: state.analyzingTotal,
                                  )
                                : const SizedBox(width: double.infinity),
                          ),
                          Expanded(
                            child: filteredItems.isEmpty
                                ? WardrobeEmptyState(
                                    category: _selectedCategory,
                                    onAddPressed: () =>
                                        AddClothingButton.pickAndUpload(context),
                                  )
                                : RefreshIndicator(
                                    color: AppColors.primary,
                                    backgroundColor: colors.surface,
                                    onRefresh: () => context
                                        .read<WardrobeCubit>()
                                        .refreshWardrobe(),
                                    child: GridView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.lg,
                                        vertical: AppSpacing.md,
                                      ),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: AppSpacing.md,
                                            mainAxisSpacing: AppSpacing.md,
                                            childAspectRatio: 0.65,
                                          ),
                                      itemCount: filteredItems.length,
                                      itemBuilder: (context, index) {
                                        final item = filteredItems[index];
                                        return ClothingCard(
                                          item: item,
                                          selectionMode: _selecting,
                                          selected: _selected.contains(item.id),
                                          onLongPress: () => _selecting
                                              ? _toggle(item.id)
                                              : _startSelection(item.id),
                                          onSelectToggle: () => _toggle(item.id),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _selecting ? null : const AddClothingButton(),
        bottomNavigationBar: AnimatedSwitcher(
          duration: _switchDuration,
          transitionBuilder: (child, animation) => SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
          child: _selecting
              ? DeleteBar(
                  key: const ValueKey('delete-bar'),
                  count: _selected.length,
                  onDelete: _deleteSelected,
                )
              : const SizedBox.shrink(key: ValueKey('no-bar')),
        ),
      ),
    );
  }
}
