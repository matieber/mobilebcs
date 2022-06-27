import 'dart:async';
import 'package:mercadosaludlib/mercadosalud.dart';

import 'package:flutter/services.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:flamingo/flamingo.dart';
import 'dart:io';

class UserService {
  final _logger = getLogger('UserService');

  Paciente? _currentUser;

  Paciente? get currentUser => _currentUser;

  bool get isEnabled => _currentUser?.enabled ?? false;

  Future populateCurrentUser(String uid) async {
    _currentUser = await getUser(uid);
  }

  Future repopulateCurrentUser() async {
    _currentUser = await getUser(_currentUser!.id);
  }

  void clearCurrentuser() {
    _currentUser = null;
  }

  Future createUser(Paciente user) async {
    try {
      final documentAccessor = DocumentAccessor();
      await documentAccessor.save(user);
      await populateCurrentUser(user.id);
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
    }
  }

  Future updateUser(Paciente user) async {
    try {
      final documentAccessor = DocumentAccessor();
      await documentAccessor.update(user);
      await populateCurrentUser(user.id);
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
    }
  }

  Future getUser(String uid) async {
    try {
      final documentAccessor = DocumentAccessor();
      return await documentAccessor.load<Paciente>(Paciente(id: uid));
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }
      return e.toString();
    }
  }

  Future existUser(String uid) async {
    try {
      final path = Document.path<Paciente>();
      final snapShot = await firestoreInstance.collection(path).doc(uid).get();
      return snapShot.exists;
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
    }
  }

  Future updateUserWithImageSelfie(Paciente user, File tituloFile) async {
    try {
      final storage = Storage();
      // fetch for uploading status
      storage.fetch();
      storage.uploader.listen((data) {
        // confirm status
        print(
            'total: ${data.totalBytes} transferred: ${data.bytesTransferred}');
      });

      final pathSelfie = '${user.documentPath}/${PacienteKey.selfie.value}';
      _logger.d(pathSelfie);

      try {
        if (user.selfie != null) await storage.delete(user.selfie!);
      } catch (e) {
        _logger.d(e);
      }

      user.selfie =
          await storage.save(pathSelfie, tituloFile, mimeType: mimeTypeJpeg);
      ;

      storage.dispose();
      _logger.d(user.toData());
      final documentAccessor = DocumentAccessor();
      await documentAccessor.update(user);
      await populateCurrentUser(user.id);
    } catch (e) {
      _logger.d(e);
      if (e is PlatformException) {
        return e.message;
      }
      return e.toString();
    }
  }

  Future createImageforSelfieAcargo(
      Paciente user, PersonaACargo aCargo, File tituloFile) async {
    try {
      final storage = Storage();
      // fetch for uploading status
      storage.fetch();
      storage.uploader.listen((data) {
        // confirm status
        print(
            'total: ${data.totalBytes} transferred: ${data.bytesTransferred}');
      });

      final pathSelfie =
          '${user.documentPath}/${PacienteKey.acargo.value}/${aCargo.dni}}';
      _logger.d(pathSelfie);

      if (aCargo.selfie != null) await storage.delete(aCargo.selfie!);

      aCargo.selfie =
          await storage.save(pathSelfie, tituloFile, mimeType: mimeTypeJpeg);
      ;

      storage.dispose();
      _logger.d(user.toData());
    } catch (e) {
      _logger.d(e);
      if (e is PlatformException) {
        return e.message;
      }
      return e.toString();
    }
  }
}
