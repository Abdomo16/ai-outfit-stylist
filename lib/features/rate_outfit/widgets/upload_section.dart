import 'dart:io';
import 'package:flutter/material.dart';

class UploadSection extends StatelessWidget {
  final File? image;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onClear;

  const UploadSection({
    super.key,
    this.image,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            height: 400,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: FileImage(image!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
              ),
              onPressed: onClear,
            ),
          ),
        ],
      );
    }

    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xff1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Upload your outfit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo or choose from gallery',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: onCameraTap,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2C2C2E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: onGalleryTap,
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2C2C2E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
