import 'package:flutter/material.dart';
import '../../../../data/models/clothing_item_model.dart';
import '../../../../data/models/outfit_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../wardrobe/utils/wardrobe_labels.dart';
import '../../wardrobe/widgets/wardrobe_item_image.dart';
import '../utils/outfit_pieces.dart';
import 'styling_progress.dart';

/// The outfit as a board of photo cards, always laid out the same way:
/// garments top to bottom in a wide column, shoes, bags and accessories in
/// a narrower one beside them.
class OutfitPreviewCard extends StatelessWidget {
  final OutfitModel outfit;
  final bool loading;

  /// Called when a piece's card is tapped.
  final ValueChanged<ClothingItemModel>? onPieceTap;

  /// Pieces marked with a pin in their card's corner.
  final Set<String> pinnedIds;

  final double height;

  const OutfitPreviewCard({
    super.key,
    required this.outfit,
    this.loading = false,
    this.onPieceTap,
    this.pinnedIds = const {},
    this.height = 380,
  });

  /// More cards than this in a column get too small to read.
  static const int _maxMain = 3;
  static const int _maxSide = 3;

  static const double _gap = 10;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pieces = orderedPieces(outfit.items);
    var main = pieces.where((item) => !isSidePiece(item)).toList();
    var side = pieces.where(isSidePiece).toList();
    if (main.isEmpty) {
      main = side.take(_maxMain).toList();
      side = side.skip(_maxMain).toList();
    } else if (main.length > _maxMain) {
      side = [...main.skip(_maxMain), ...side];
      main = main.take(_maxMain).toList();
    }

    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // A new outfit fades in over the old one.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: pieces.isEmpty
                ? Icon(
                    Icons.checkroom,
                    size: 64,
                    color: colors.onSurfaceVariant,
                  )
                : Row(
                    key: ValueKey(pieces.map((item) => item.id).join(',')),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: _column(main, padding: 14)),
                      if (side.isNotEmpty) ...[
                        const SizedBox(width: _gap),
                        Expanded(flex: 2, child: _sideColumn(side)),
                      ],
                    ],
                  ),
          ),
          if (loading)
            ColoredBox(
              color: colors.surface.withValues(alpha: 0.75),
              child: const Center(child: StylingProgress()),
            ),
        ],
      ),
    );
  }

  Widget _column(List<ClothingItemModel> items, {required double padding}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: _gap),
          Expanded(
            child: _PieceCard(
              key: ValueKey(items[i].id),
              item: items[i],
              padding: padding,
              pinned: pinnedIds.contains(items[i].id),
              onTap: onPieceTap == null ? null : () => onPieceTap!(items[i]),
            ),
          ),
        ],
      ],
    );
  }

  /// Up to [_maxSide] cards; the last one counts the pieces that did not
  /// fit, which are all listed under the board.
  Widget _sideColumn(List<ClothingItemModel> items) {
    if (items.length <= _maxSide) return _column(items, padding: 10);
    final shown = items.take(_maxSide).toList();
    final hidden = items.length - _maxSide + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0) const SizedBox(height: _gap),
          Expanded(
            child: _PieceCard(
              key: ValueKey(shown[i].id),
              item: shown[i],
              padding: 10,
              pinned: pinnedIds.contains(shown[i].id),
              moreCount: i == shown.length - 1 ? hidden : null,
              onTap: onPieceTap == null ? null : () => onPieceTap!(shown[i]),
            ),
          ),
        ],
      ],
    );
  }
}

/// One piece on the board: a white card with a soft shadow, the photo
/// centered inside with an even margin.
class _PieceCard extends StatelessWidget {
  final ClothingItemModel item;
  final double padding;
  final VoidCallback? onTap;
  final bool pinned;

  /// When set, the card is covered by a "+N" for pieces left off the board.
  final int? moreCount;

  const _PieceCard({
    super.key,
    required this.item,
    required this.padding,
    this.onTap,
    this.pinned = false,
    this.moreCount,
  });

  static const double _radius = 20;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final cutout = item.cutoutUrl;
    final hasCutout = cutout != null && cutout.startsWith('http');

    Widget photo = WardrobeItemImage(
      imageUrl: hasCutout ? cutout : item.imageUrl,
      iconSize: 32,
      backdrop: hasCutout
          ? Colors.transparent
          : WardrobeItemImage.defaultBackdrop,
    );
    // A photo that kept its own background gets rounded corners so it
    // reads as a picture inside the card, not a box stuck to its edge.
    if (!hasCutout) {
      photo = ClipRRect(borderRadius: BorderRadius.circular(12), child: photo);
    }

    return Semantics(
      button: onTap != null,
      label: WardrobeLabels.type(l10n, item.type),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(_radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(padding: EdgeInsets.all(padding), child: photo),
                if (pinned)
                  PositionedDirectional(
                    top: 6,
                    end: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.push_pin,
                        size: 12,
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                if (moreCount != null)
                  ColoredBox(
                    color: colors.surface.withValues(alpha: 0.82),
                    child: Center(
                      child: Text(
                        '+$moreCount',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
