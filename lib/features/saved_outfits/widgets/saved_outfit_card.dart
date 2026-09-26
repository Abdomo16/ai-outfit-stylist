import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import 'outfit_image_collage.dart';

class SavedOutfitCard extends StatelessWidget {
  final Map<String, dynamic> outfit;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SavedOutfitCard({
    super.key,
    required this.outfit,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final outfitData = outfit['outfit_data'] as Map<String, dynamic>? ?? {};
    final name = outfitData['name'] as String? ?? 'Saved Outfit';
    final occasion = outfitData['occasion'] as String? ?? '';
    final style =
        outfitData['stylePreference'] as String? ??
        outfitData['occasion'] as String? ??
        '';

    // Extract image URLs from items list
    final rawItems = outfitData['items'] as List<dynamic>? ?? [];
    final imageUrls = rawItems
        .map((i) {
          final item = i as Map<String, dynamic>? ?? {};
          return (item['imageUrl'] ?? item['image_path']) as String?;
        })
        .where((url) => url != null && url.isNotEmpty)
        .cast<String>()
        .take(4)
        .toList();

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: colors.outline),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image collage
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    OutfitImageCollage(
                      imageUrls: imageUrls,
                      fallbackStyle: style.isEmpty ? '' : style,
                      errorIconSize: 24,
                    ),
                    // Bottom gradient for depth
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.35),
                            ],
                            stops: const [0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Action buttons
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionCircleButton(
                            icon: Icons.share,
                            tooltip: 'Share',
                            onTap: () {
                              final text =
                                  'Check out this outfit I styled: $name'
                                  '${occasion.isNotEmpty ? ' for $occasion' : ''}!';
                              Share.share(text);
                            },
                          ),
                          const SizedBox(width: 8),
                          _ActionCircleButton(
                            icon: Icons.close,
                            tooltip: 'Remove',
                            onTap: onDelete,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Info
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (occasion.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.event,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              occasion,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black54,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }
}
