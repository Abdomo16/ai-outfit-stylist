import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/clothing_item_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/wardrobe_colors.dart';
import '../../../../core/constants/wardrobe_taxonomy.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/wardrobe_cubit.dart';
import '../utils/wardrobe_labels.dart';
import '../widgets/wardrobe_item_image.dart';

class EditClothingScreen extends StatefulWidget {
  final ClothingItemModel item;

  const EditClothingScreen({super.key, required this.item});

  @override
  State<EditClothingScreen> createState() => _EditClothingScreenState();
}

class _EditClothingScreenState extends State<EditClothingScreen> {
  late TextEditingController _nameController;
  late String _selectedCategory;
  late String _selectedType;
  late String _selectedColor;

  /// Empty means the item has a single color.
  late String _selectedSecondary;
  late final List<String> _colorOptions;

  static const _noColor = '';

  @override
  void initState() {
    super.initState();
    final name = widget.item.name;
    _nameController = TextEditingController(
      text: name.toLowerCase() == widget.item.type.toLowerCase() ? '' : name,
    );

    // Ensure the initial value exists in the list, otherwise default to the first
    _selectedCategory =
        widget.item.category ?? WardrobeTaxonomy.categories.first;
    final type = WardrobeTaxonomy.canonicalType(widget.item.type);
    final types = WardrobeTaxonomy.typesFor(_selectedCategory);
    _selectedType = types.contains(type) ? type : types.first;

    // An unknown stored color stays selectable so saving does not change it.
    _selectedColor = WardrobeColors.canonical(widget.item.color);
    _colorOptions = [
      ...WardrobeColors.names,
      if (!WardrobeColors.isKnown(_selectedColor) && _selectedColor.isNotEmpty)
        _selectedColor,
    ];
    if (_selectedColor.isEmpty) _selectedColor = WardrobeColors.names.first;
    final secondary = WardrobeColors.canonical(widget.item.secondaryColor);
    _selectedSecondary = WardrobeColors.isKnown(secondary) ? secondary : _noColor;
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedType = WardrobeTaxonomy.typesFor(category).first;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final item = widget.item;
    // Keep the measured shade unless the user picked a different color.
    final colorChanged = WardrobeColors.canonical(item.color) != _selectedColor;
    final secondaryChanged =
        WardrobeColors.canonical(item.secondaryColor) != _selectedSecondary;
    final updatedItem = item.copyWith(
      name: _nameController.text.trim(),
      category: _selectedCategory,
      type: _selectedType,
      color: _selectedColor,
      hex: colorChanged ? WardrobeColors.hexOf(_selectedColor) : null,
      clearSecondary: _selectedSecondary == _noColor,
      secondaryColor: _selectedSecondary == _noColor ? null : _selectedSecondary,
      secondaryHex: secondaryChanged && _selectedSecondary != _noColor
          ? WardrobeColors.hexOf(_selectedSecondary)
          : null,
    );

    context.read<WardrobeCubit>().updateClothingItem(updatedItem);
    Navigator.pop(context, updatedItem); // Return the updated item
  }

  List<DropdownMenuItem<String>> _colorItems(
    AppLocalizations l10n,
    ColorScheme colors,
    List<String> options,
    String selected,
  ) {
    return options.map((color) {
      final swatch = WardrobeColors.swatches[color];
      return DropdownMenuItem(
        value: color,
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsetsDirectional.only(end: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: swatch ?? Colors.transparent,
                border: Border.all(
                  color: selected == color ? AppColors.primary : colors.outline,
                  width: 2,
                ),
              ),
              child: swatch == null
                  ? Icon(Icons.block, size: 12, color: colors.onSurfaceVariant)
                  : null,
            ),
            Text(
              color == _noColor
                  ? l10n.colorNone
                  : WardrobeLabels.color(l10n, color),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildImagePreview() {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final width = MediaQuery.of(context).size.width;
    return WardrobeItemImage(
      imageUrl: widget.item.imageUrl,
      iconSize: 56,
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // We use a custom back button
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: colors.onSurface,
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Edit Item',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            const SizedBox(width: 36), // To balance the center title
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Preview
              Center(
                child: Hero(
                  tag: 'image_${widget.item.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      height: 320,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildImagePreview(),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.heroGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'AI SCANNED',
                                style: TextStyle(
                                  color: colors.onPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Name Field
              Text(
                'ITEM NAME',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: TextStyle(color: colors.onSurface, fontSize: 16),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colors.surface,
                  suffixIcon: Icon(
                    Icons.edit,
                    color: colors.onSurfaceVariant,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),

              // Category Field
              Text(
                'CATEGORY',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outline),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    dropdownColor: colors.surface,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: colors.onSurfaceVariant,
                    ),
                    style: TextStyle(color: colors.onSurface, fontSize: 16),
                    items: WardrobeTaxonomy.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(WardrobeLabels.category(l10n, cat)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) _selectCategory(val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Type Field
              Text(
                'TYPE',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outline),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    dropdownColor: colors.surface,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: colors.onSurfaceVariant,
                    ),
                    style: TextStyle(color: colors.onSurface, fontSize: 16),
                    items: WardrobeTaxonomy.typesFor(_selectedCategory).map((
                      type,
                    ) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(WardrobeLabels.type(l10n, type)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Color Field
              Text(
                'COLOR',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outline),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedColor,
                    dropdownColor: colors.surface,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: colors.onSurfaceVariant,
                    ),
                    style: TextStyle(color: colors.onSurface, fontSize: 16),
                    items: _colorItems(l10n, colors, _colorOptions, _selectedColor),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedColor = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Second color, for stripes, plaid and other patterns
              Text(
                'SECOND COLOR',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outline),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSecondary,
                    dropdownColor: colors.surface,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: colors.onSurfaceVariant,
                    ),
                    style: TextStyle(color: colors.onSurface, fontSize: 16),
                    items: _colorItems(
                      l10n,
                      colors,
                      [_noColor, ...WardrobeColors.names],
                      _selectedSecondary,
                    ),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSecondary = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Bottom Actions
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: AppColors.heroGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: MaterialButton(
                  onPressed: _saveChanges,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_outlined, color: colors.onPrimary),
                      const SizedBox(width: 8),
                      Text(
                        'Save Changes',
                        style: TextStyle(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outline),
                ),
                child: MaterialButton(
                  onPressed: () {
                    context.read<WardrobeCubit>().deleteClothingItem(
                      widget.item.id ?? '',
                    );
                    Navigator.pop(context); // Pop edit screen
                    Navigator.pop(
                      context,
                    ); // Pop detail screen to go back to wardrobe
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Delete Item',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
