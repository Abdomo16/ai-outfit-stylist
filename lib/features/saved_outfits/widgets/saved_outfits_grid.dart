import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/saved_outfits_cubit.dart';
import '../screens/saved_outfit_detail_screen.dart';
import 'saved_outfit_card.dart';

class SavedOutfitsGrid extends StatelessWidget {
  final List<dynamic> outfits;

  const SavedOutfitsGrid({super.key, required this.outfits});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: outfits.length,
      itemBuilder: (context, index) {
        final outfit = outfits[index] as Map<String, dynamic>;
        return SavedOutfitCard(
          outfit: outfit,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    SavedOutfitDetailScreen(outfit: outfit),
              ),
            );
          },
          onDelete: () => _confirmDelete(context, outfit['id'].toString()),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Outfit?'),
        content: const Text(
          'This outfit will be removed from your saved collection.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<SavedOutfitsCubit>().deleteOutfit(id);
    }
  }
}
