import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../cubit/wardrobe_cubit.dart';

class AddClothingButton extends StatelessWidget {
  const AddClothingButton({super.key});

  static Future<void> pickAndUpload(BuildContext context) async {
    final imagePaths = await ImagePickerHelper.pickImagesFromGallery();
    if (imagePaths.isEmpty) return;

    if (!context.mounted) return;

    context.read<WardrobeCubit>().addClothingItems(
      imagePaths.map((path) => File(path)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.heroGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () => pickAndUpload(context),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}
