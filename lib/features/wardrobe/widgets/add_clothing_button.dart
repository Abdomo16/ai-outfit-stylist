import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../cubit/wardrobe_cubit.dart';

class AddClothingButton extends StatelessWidget {
  const AddClothingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFFB388FF), // Lighter Purple
            Color(0xFF8A3FFC), // Primary Purple
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent, // Transparent to show gradient
        elevation: 0,
        foregroundColor: Colors.white,
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final imagePath = await ImagePickerHelper.pickImageFromGallery();
    if (imagePath == null) return;

    if (!context.mounted) return;

    // Immediately upload the image, the AI backend extracts everything
    context.read<WardrobeCubit>().addClothingItem(File(imagePath));
  }
}
