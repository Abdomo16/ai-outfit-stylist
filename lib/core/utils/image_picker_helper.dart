import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  ImagePickerHelper._();

  static final ImagePicker _picker = ImagePicker();

  static const double _maxWidth = 1280;
  static const int _imageQuality = 80;

  static Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxWidth,
        imageQuality: _imageQuality,
      );
      return image?.path;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  static Future<List<String>> pickImagesFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: _maxWidth,
        imageQuality: _imageQuality,
      );
      return images.map((image) => image.path).toList();
    } catch (e) {
      print('Error picking images: $e');
      return const [];
    }
  }

  static Future<String?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: _maxWidth,
        imageQuality: _imageQuality,
      );
      return photo?.path;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }
}
