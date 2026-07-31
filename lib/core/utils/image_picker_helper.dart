import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  ImagePickerHelper._();

  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      return image?.path;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  static Future<String?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      return photo?.path;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }
}
