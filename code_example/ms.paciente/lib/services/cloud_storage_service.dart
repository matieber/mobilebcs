import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mercadosalud/app/app.logger.dart';

class CloudStorageService {
  final _logger = getLogger('CloudStorageService');

  Future<CloudStorageResult?> uploadImage({
    required File imageToUpload,
    required String title,
  }) async {
    var imageFileName =
        title + DateTime.now().millisecondsSinceEpoch.toString();

    final Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(imageFileName);

    UploadTask uploadTask = firebaseStorageRef.putFile(imageToUpload);
    await uploadTask;
    final downloadUrl = await firebaseStorageRef.getDownloadURL();
    _logger.d("url: $downloadUrl");
    var url = downloadUrl.toString();
    return CloudStorageResult(
      imageUrl: url,
      imageFileName: imageFileName,
    );
  }

  Future deleteImage(String imageFileName) async {
    final Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(imageFileName);

    try {
      await firebaseStorageRef.delete();
      return true;
    } catch (e) {
      return e.toString();
    }
  }
}

class CloudStorageResult {
  final String imageUrl;
  final String imageFileName;

  CloudStorageResult({required this.imageUrl, required this.imageFileName});
}
