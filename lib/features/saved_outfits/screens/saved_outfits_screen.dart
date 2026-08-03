import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/saved_outfits_cubit.dart';
import '../cubit/saved_outfits_state.dart';
import '../widgets/saved_outfits_empty_state.dart';
import '../widgets/saved_outfits_error_view.dart';
import '../widgets/saved_outfits_grid.dart';

class SavedOutfitsScreen extends StatefulWidget {
  const SavedOutfitsScreen({super.key});

  @override
  State<SavedOutfitsScreen> createState() => _SavedOutfitsScreenState();
}

class _SavedOutfitsScreenState extends State<SavedOutfitsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedOutfitsCubit>().fetchSavedOutfits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<SavedOutfitsCubit, SavedOutfitsState>(
          builder: (context, state) {
            final count = state is SavedOutfitsLoaded
                ? state.savedOutfits.length
                : null;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Saved Outfits',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                if (count != null && count > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<SavedOutfitsCubit, SavedOutfitsState>(
        builder: (context, state) {
          if (state is SavedOutfitsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is SavedOutfitsError) {
            return SavedOutfitsErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<SavedOutfitsCubit>().fetchSavedOutfits(),
            );
          }

          if (state is SavedOutfitsLoaded) {
            if (state.savedOutfits.isEmpty) {
              return const SavedOutfitsEmptyState();
            }
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<SavedOutfitsCubit>().fetchSavedOutfits(),
              color: AppColors.primary,
              child: SavedOutfitsGrid(outfits: state.savedOutfits),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
