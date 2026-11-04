import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/datasources/ai_service.dart';
import '../../../data/models/outfit_model.dart';
import '../../../data/repositories/wardrobe_repository_impl.dart';
import '../../../l10n/app_localizations.dart';
import '../../outfit_generator/cubit/outfit_cubit.dart';
import '../../outfit_generator/screens/outfit_result_screen.dart';
import '../../outfit_generator/utils/outfit_pieces.dart';
import '../../wardrobe/widgets/wardrobe_item_image.dart';

/// Opens [outfit] on the result screen, where it can be pinned, swapped and
/// regenerated.
void openOutfitResult(
  BuildContext context,
  OutfitModel outfit, {
  String? weather,
  String? season,
}) {
  final aiService = AIService();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => OutfitCubit(
          WardrobeRepositoryImpl(aiService: aiService),
          aiService,
        )..show(outfit, weather: weather, season: season),
        child: const OutfitResultScreen(),
      ),
    ),
  );
}

class ChatOutfitCard extends StatelessWidget {
  final OutfitModel outfit;
  final VoidCallback onOpen;

  const ChatOutfitCard({super.key, required this.outfit, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final pieces = orderedPieces(outfit.items);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 76,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: pieces.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (_, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 64,
                      child: WardrobeItemImage(
                        imageUrl: pieces[index].imageUrl,
                        iconSize: 24,
                        memCacheWidth: 200,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    l10n.chatViewLook,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
