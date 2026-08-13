import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../data/models/clothing_item_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/item_info_card.dart';
import '../widgets/detail_action_buttons.dart';
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
    final url = _item.imageUrl;
    final Widget fallback = Container(
      color: AppColors.card,
      child: const Center(
        child: Icon(
          Icons.checkroom,
          size: 48,
          color: AppColors.textSecondary,
        ),
      ),
    );

    if (url == null || url.isEmpty) return fallback;

    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    if (File(url).existsSync()) {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                            AppColors.background,
                            AppColors.background.withOpacity(0.0),
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
                          _item.name.isEmpty
                              ? '${_item.color} ${_item.category}'.toUpperCase()
                              : _item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
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
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 32),

                  ItemInfoCard(
                    icon: Icons.category,
                    label: 'CATEGORY',
                    value: _item.category.toUpperCase(),
                  ),
                  const SizedBox(height: 16),
                  ItemInfoCard(
                    icon: Icons.palette,
                    label: 'COLOR',
                    value: _item.color.toUpperCase(),
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
