import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/wardrobe_cubit.dart';
import '../cubit/wardrobe_state.dart';
import '../widgets/clothing_card.dart';
import '../widgets/add_clothing_button.dart';
import '../widgets/wardrobe_header.dart';
import '../widgets/category_tabs.dart';

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
    'Shoes',
    'Jackets',
    'Accessories',
  ];

  @override
  void initState() {
    super.initState();
    context.read<WardrobeCubit>().loadWardrobeItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is WardrobeLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  } else if (state is WardrobeLoaded) {
                    final filteredItems = _selectedCategory == 'All'
                        ? state.items
                        : state.items
                              .where(
                                (item) =>
                                    item.category.toLowerCase() ==
                                    _selectedCategory.toLowerCase(),
                              )
                              .toList();

                    if (filteredItems.isEmpty) {
                      return Center(
                        child: Text(
                          _selectedCategory == 'All'
                              ? 'Your wardrobe is empty.'
                              : 'No items found in $_selectedCategory.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.card,
                      onRefresh: () =>
                          context.read<WardrobeCubit>().refreshWardrobe(),
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio:
                                  0.65, // Adjusted for taller cards
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
