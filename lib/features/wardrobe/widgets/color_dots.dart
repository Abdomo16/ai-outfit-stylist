import 'package:flutter/material.dart';
import '../../../../core/constants/wardrobe_colors.dart';
import '../../../../data/models/clothing_item_model.dart';

/// The item's color, and its second color when it has one, as small swatches.
class ColorDots extends StatelessWidget {
  final ClothingItemModel item;
  final double size;

  const ColorDots({super.key, required this.item, this.size = 12});

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    final swatches = [
      WardrobeColors.swatchFor(item.color, item.hex),
      if (item.secondaryColor != null)
        WardrobeColors.swatchFor(item.secondaryColor, item.secondaryHex),
    ].whereType<Color>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final swatch in swatches)
          Container(
            width: size,
            height: size,
            margin: EdgeInsetsDirectional.only(start: size / 3),
            decoration: BoxDecoration(
              color: swatch,
              shape: BoxShape.circle,
              border: Border.all(color: outline),
            ),
          ),
      ],
    );
  }
}
