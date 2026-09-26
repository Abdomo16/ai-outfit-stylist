import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/clothing_item_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/wardrobe_cubit.dart';

class EditClothingScreen extends StatefulWidget {
  final ClothingItemModel item;

  const EditClothingScreen({super.key, required this.item});

  @override
  State<EditClothingScreen> createState() => _EditClothingScreenState();
}

class _EditClothingScreenState extends State<EditClothingScreen> {
  late TextEditingController _nameController;
  late String _selectedCategory;
  late String _selectedColor;

  final _categories = [
    'Shirts',
    'Pants',
    'Jackets',
    'Shoes',
    'Accessories',
    'Outerwear',
  ];
  final _colors = [
    'Black',
    'White',
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Indigo',
    'Beige',
    'Pattern',
  ];

  static const _colorValues = <String, Color>{
    'Black': Colors.black,
    'White': Colors.white,
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Yellow': Colors.yellow,
    'Indigo': Colors.indigo,
    'Beige': Color(0xFFE8DCC8),
    'Pattern': AppColors.primary,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);

    // Ensure the initial value exists in the list, otherwise default to the first
    _selectedCategory = _categories.contains(widget.item.category)
        ? widget.item.category
        : _categories.first;

    _selectedColor = _colors.contains(widget.item.color)
        ? widget.item.color
        : _colors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedItem = widget.item.copyWith(
      name: _nameController.text.trim(),
      category: _selectedCategory,
      color: _selectedColor,
    );

    context.read<WardrobeCubit>().updateClothingItem(updatedItem);
    Navigator.pop(context, updatedItem); // Return the updated item
  }

  Widget _buildImagePreview() {
    final url = widget.item.imageUrl;
    final colors = Theme.of(context).colorScheme;
    final Widget fallback = Container(
      color: colors.surface,
      child: Icon(
        Icons.checkroom,
        size: 56,
        color: colors.onSurfaceVariant,
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
                    items: _categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
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
                    items: _colors.map((color) {
                      return DropdownMenuItem(
                        value: color,
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _colorValues[color],
                                border: Border.all(
                                  color: color == 'White'
                                      ? Colors.white38
                                      : _selectedColor == color
                                      ? AppColors.primary
                                      : colors.outline,
                                  width: 2,
                                ),
                              ),
                            ),
                            Text(color),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedColor = val);
                    },
                  ),
                ),
              ),

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
