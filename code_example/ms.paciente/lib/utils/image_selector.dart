import 'package:image_picker/image_picker.dart';
import 'package:mercadosalud/app/app.logger.dart';

class ImageSelector {
  final _logger = getLogger('UI');

  Future<PickedFile?> selectImage() async {
    final _picker = ImagePicker();
    final file = await _picker.getImage(source: ImageSource.gallery);
    _logger.d("Result: $file");

    return file;
  }
}
