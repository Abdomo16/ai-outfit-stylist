import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/wardrobe_cubit.dart';
import '../cubit/wardrobe_state.dart';
import '../widgets/clothing_card.dart';
import '../widgets/add_clothing_button.dart';
import '../widgets/wardrobe_header.dart';
import '../widgets/category_tabs.dart';
import '../widgets/wardrobe_empty_state.dart';
import '../utils/category_utils.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Shirts',
    'Pants',
    'Jackets',
    'Shoes',
    'Accessories',
  ];

  @override
  void initState() {
    super.initState();
    context.read<WardrobeCubit>().loadWardrobeItems();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WardrobeHeader(),
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
                    final filteredItems = _selectedCategory == 'All'
                        ? state.items
                        : state.items
                              .where(
                                (item) => CategoryUtils.matchesCategory(
                                  item.category,
                                  _selectedCategory,
                                ),
                              )
                              .toList();

                    if (filteredItems.isEmpty) {
                      return WardrobeEmptyState(
                        category: _selectedCategory,
                        onAddPressed: () => AddClothingButton.pickAndUpload(context),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: colors.surface,
                      onRefresh: () =>
                          context.read<WardrobeCubit>().refreshWardrobe(),
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
                          return ClothingCard(item: filteredItems[index]);
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const AddClothingButton(),
    );
  }
}
