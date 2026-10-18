import 'package:flutter/material.dart';
import '../../../../data/models/clothing_item_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../utils/wardrobe_labels.dart';
import '../widgets/color_dots.dart';
import '../widgets/item_info_card.dart';
import '../widgets/detail_action_buttons.dart';
import '../widgets/wardrobe_item_image.dart';
import 'edit_clothing_screen.dart';

class ClothingDetailScreen extends StatefulWidget {
  final ClothingItemModel item;

  const ClothingDetailScreen({super.key, required this.item});

  @override
  State<ClothingDetailScreen> createState() => _ClothingDetailScreenState();
}

class _ClothingDetailScreenState extends State<ClothingDetailScreen> {
  late ClothingItemModel _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.push<ClothingItemModel>(
      context,
      MaterialPageRoute(builder: (_) => EditClothingScreen(item: _item)),
    );
    if (updated != null && mounted) {
      setState(() => _item = updated);
    }
  }

  Widget _buildImage() {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final width = MediaQuery.of(context).size.width;
    return WardrobeItemImage(
      imageUrl: _item.imageUrl,
      iconSize: 48,
      memCacheWidth: (width * dpr).round().clamp(400, 1200),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 400,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'ITEM DETAILS',
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            actions: [
              // Placeholder for future share icon if needed
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(),
                  // Gradient overlay at the bottom of the image
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            theme.scaffoldBackgroundColor,
                            theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          WardrobeLabels.title(l10n, _item),
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${(_item.id ?? '').length > 8 ? (_item.id ?? '').substring(0, 8) : (_item.id ?? '')} • Added recently',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 32),

                  ItemInfoCard(
                    icon: Icons.category,
                    label: 'CATEGORY',
                    value: WardrobeLabels.category(
                      l10n,
                      _item.category ?? '-',
                    ).toUpperCase(),
                  ),
                  const SizedBox(height: 16),
                  ItemInfoCard(
                    icon: Icons.checkroom,
                    label: 'TYPE',
                    value: WardrobeLabels.type(l10n, _item.type).toUpperCase(),
                  ),
                  const SizedBox(height: 16),
                  ItemInfoCard(
                    icon: Icons.palette,
                    label: 'COLOR',
                    value: WardrobeLabels.colors(l10n, _item).toUpperCase(),
                    trailing: ColorDots(item: _item, size: 18),
                  ),
                  const SizedBox(height: 16),
                  if (_item.season != null && _item.season!.isNotEmpty)
                    ItemInfoCard(
                      icon: Icons.thermostat,
                      label: 'SEASON',
                      value: _item.season!.toUpperCase(),
                    ),
                  if (_item.season != null && _item.season!.isNotEmpty)
                    const SizedBox(height: 16),
                  if (_item.pattern != null &&
                      _item.pattern!.isNotEmpty &&
                      _item.pattern!.toLowerCase() != 'solid')
                    ItemInfoCard(
                      icon: Icons.texture,
                      label: 'PATTERN',
                      value: _item.pattern!.toUpperCase(),
                    ),

                  const SizedBox(height: 48),
                  DetailActionButtons(item: _item, onEdit: _openEdit),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
