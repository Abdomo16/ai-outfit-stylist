import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../data/models/clothing_item_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/item_info_card.dart';
import '../widgets/detail_action_buttons.dart';

class ClothingDetailScreen extends StatelessWidget {
  final ClothingItemModel item;

  const ClothingDetailScreen({super.key, required this.item});

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
                  (item.imageUrl ?? '').startsWith('http')
                      ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                      : Image.file(
                          File(item.imageUrl ?? ''),
                          fit: BoxFit.cover,
                        ),
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
                          item.name.isEmpty
                              ? '${item.color} ${item.category}'.toUpperCase()
                              : item.name,
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
                    'ID: ${(item.id ?? '').length > 8 ? (item.id ?? '').substring(0, 8) : (item.id ?? '')} • Added recently',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 32),

                  ItemInfoCard(
                    icon: Icons.category,
                    label: 'CATEGORY',
                    value: item.category.toUpperCase(),
                  ),
                  const SizedBox(height: 16),
                  ItemInfoCard(
                    icon: Icons.palette,
                    label: 'COLOR',
                    value: item.color.toUpperCase(),
                  ),
                  const SizedBox(height: 16),
                  if (item.season != null && item.season!.isNotEmpty)
                    ItemInfoCard(
                      icon: Icons.thermostat,
                      label: 'SEASON',
                      value: item.season!.toUpperCase(),
                    ),
                  if (item.season != null && item.season!.isNotEmpty)
                    const SizedBox(height: 16),
                  if (item.pattern != null &&
                      item.pattern!.isNotEmpty &&
                      item.pattern!.toLowerCase() != 'solid')
                    ItemInfoCard(
                      icon: Icons.texture,
                      label: 'PATTERN',
                      value: item.pattern!.toUpperCase(),
                    ),

                  const SizedBox(height: 48),
                  DetailActionButtons(item: item),
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
