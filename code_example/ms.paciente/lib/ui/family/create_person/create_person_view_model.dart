import 'dart:io';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosaludlib/mercadosalud.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mercadosalud/services/cloud_storage_service.dart';
import 'package:mercadosalud/services/user_service.dart';
import 'package:mercadosalud/services/authentication_service.dart';
import 'package:mercadosalud/services/user_service.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class CreatePersonViewModel extends BaseViewModel {
  final _firestoreService = locator<UserService>();

  final _bottomSheetService = locator<BottomSheetService>();

  final NavigationService _navigationService = locator<NavigationService>();
  final _firebaseAuthenticationService = locator<AuthenticationService>();

  final _logger = getLogger('CreatePersonViewModel');

  PersonaACargo? _edittingPost;
  List<PersonaACargo>? _persons;

  bool get _editting => _edittingPost != null;

  get relaciones => _relaciones;

  final _relaciones = [
    FormBuilderFieldOption(value: 'Hija/o', child: Text('Hija/o')),
    FormBuilderFieldOption(value: 'Esposa/o', child: Text('Esposa/o')),
    FormBuilderFieldOption(value: 'Abuela/o', child: Text('Abuela/o')),
    FormBuilderFieldOption(value: 'Nieta/o', child: Text('Nieta/o')),
    FormBuilderFieldOption(value: 'Tia/o', child: Text('Tia/o')),
    FormBuilderFieldOption(value: 'Sobrina/o', child: Text('Sobrina/o')),
    FormBuilderFieldOption(value: 'Familiar', child: Text('Familiar')),
    FormBuilderFieldOption(value: 'Amiga/o', child: Text('Amiga/o')),
    FormBuilderFieldOption(value: 'Otro', child: Text('Otro')),
  ];

  Future submitIfValid(FormBuilderState form) async {
    if (form.saveAndValidate()) {
      _logger.d("Valid data form");
      await submit(form);
    } else {
      _logger.d("Invalid data form");
    }
  }

  Future submit(FormBuilderState form) async {
    setBusy(true);

/*
    if (!_editting) {
      result = await _firestoreService.addPost(Post(
        title: title,
        //userId: currentUser.id,
        userId: _firebaseAuthenticationService.currentUser!.id!,
        imageUrl: storageResult!.imageUrl,
        imageFileName: storageResult.imageFileName,
      ));
    } else {
      result = await _firestoreService.updatePost(Post(
        title: title,
        userId: _edittingPost!.userId,
        documentId: _edittingPost!.documentId,
        imageUrl: _edittingPost!.imageUrl,
        imageFileName: _edittingPost!.imageFileName,
      ));
    }*/

    _edittingPost!.fullName = form.fields["fullname"]!.value;
    _edittingPost!.relationship = form.fields["relationship"]!.value;
    _edittingPost!.dni = int.parse(form.fields["dni"]!.value);

    //var file_selfie = form.fields["selfie"]!.value[0];

    var fileSelfie = null;
    final arrayImage = form.fields["selfie"]?.value;
    if (arrayImage.length > 0)
      fileSelfie = (form.fields["selfie"]!.value[0]) is File
          ? (form.fields["selfie"]!.value[0])
          : null;

    //si  cambio la imagen  la subo
    if (fileSelfie != null)
      await _firestoreService.createImageforSelfieAcargo(
          _firebaseAuthenticationService.currentUser!,
          _edittingPost!,
          fileSelfie!);

    _persons?.add(_edittingPost!);

    setBusy(false);

    /*if (result is String) {
      await _bottomSheetService.showBottomSheet(
        title: 'Cound not create post',
        description: result,
      );
    } else {
      await _bottomSheetService.showBottomSheet(
        title: 'Post successfully Added',
        description: 'Your post has been created',
      );
    }*/

    _navigationService.back();
  }

  void setEdittingPost(PersonaACargo edittingPost,
      {List<PersonaACargo>? persons = null}) {
    _edittingPost = edittingPost;
    _persons = persons;
  }
}
