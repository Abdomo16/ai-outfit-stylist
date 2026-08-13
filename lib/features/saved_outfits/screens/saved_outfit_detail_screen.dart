import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/circular_icon_button.dart';
import '../widgets/outfit_image_collage.dart';
import '../widgets/outfit_piece_card.dart';

class SavedOutfitDetailScreen extends StatelessWidget {
  final Map<String, dynamic> outfit;

  const SavedOutfitDetailScreen({super.key, required this.outfit});

  @override
  Widget build(BuildContext context) {
    final outfitData = outfit['outfit_data'] as Map<String, dynamic>? ?? {};
    final name = outfitData['name'] as String? ?? 'Saved Outfit';
    final occasion = outfitData['occasion'] as String? ?? '';
    final stylePreference =
        outfitData['stylePreference'] as String? ??
        outfitData['style'] as String? ??
        '';
    final items = _parseItems(outfitData['items']);
    final createdAt = outfit['created_at'] as String?;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.card,
            leading: CircularIconButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: OutfitImageCollage(
                imageUrls: items.map(_imageUrl).whereType<String>().toList(),
                fallbackStyle:
                    stylePreference.isNotEmpty
                        ? stylePreference
                        : occasion,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, name, occasion, stylePreference),
                  if (createdAt != null && createdAt.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(createdAt),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Outfit Pieces',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (items.isEmpty)
                    _buildEmptyItems()
                  else
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: OutfitPieceCard(item: item),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _imageUrl(Map<String, dynamic> item) {
    return (item['imageUrl'] ?? item['image_path']) as String?;
  }

  Widget _buildHeader(
    BuildContext context,
    String name,
    String occasion,
    String stylePreference,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (occasion.isNotEmpty) ...[
              _buildChip(icon: Icons.event, label: occasion),
              const SizedBox(width: 8),
            ],
            if (stylePreference.isNotEmpty)
              _buildChip(icon: Icons.auto_awesome, label: stylePreference),
          ],
        ),
      ],
    );
  }

  Widget _buildChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _parseItems(dynamic rawItems) {
    if (rawItems is! List) return [];
    return rawItems.whereType<Map>().cast<Map<String, dynamic>>().toList();
  }

  Widget _buildEmptyItems() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.checkroom, size: 40, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text(
            'No clothing details available for this outfit.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return 'Saved on ${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
