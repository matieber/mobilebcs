import 'package:mercadosaludlib/mercadosalud.dart';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/app/app.router.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';

import 'package:stacked/stacked.dart';

//import 'package:mercadosalud/services/firebase_authentication_service.dart';

import 'package:mercadosalud/services/authentication_service.dart';

import 'package:stacked_services/stacked_services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:mercadosalud/services/user_service.dart';
import 'dart:io';

class AddressSelectionViewModel extends BaseViewModel {
  final _firebaseAuthenticationService = locator<AuthenticationService>();
  final _backendFirebaseAuthenticationService =
      locator<FirebaseAuthenticationService>();
  final _logger = getLogger('AddressSelectionViewModel');
  final _navigationService = locator<NavigationService>();
  final _firestoreService = locator<UserService>();

  String? get phone => _firebaseAuthenticationService.currentUser!.phone;

  String? get selfieUrl =>
      _firebaseAuthenticationService.currentUser!.selfie?.url;

  Future runStartUpLogic(FormBuilderState form) async {
    final user = _firebaseAuthenticationService.currentUser!;
    final user_address = user.address;

    if (user_address != null) {
      final data = user_address.toData();

      //conversion de  int a String para numero
      data['number'] = data['number'].toString();
      data['city'] = user.address!.cityCap;
      data['dni'] = user.dni.toString();
      data['fullName'] = user.fullNameCap;
      data['sex'] = user.sex;
      data['phone'] = _firebaseAuthenticationService.currentUser!.phone;
      _logger.d(data);
      form.patchValue(data);
      notifyListeners();
    }
  }

  Future submitIfValid(FormBuilderState form) async {
    if (form.saveAndValidate()) {
      _logger.d("Valid data form");
      final result = await runBusyFuture(submit(form));
    } else {
      _logger.d("Invalid data form");
    }
  }

  Future submit(FormBuilderState form) async {
    try {
      final Map<String, dynamic> val_form = Map.from(form.value);
      //conversion de string a int para duracion turno
      val_form['number'] = int.parse(val_form['number']);
      val_form['dni'] = int.parse(val_form['dni']);
      val_form['city'] = (val_form['city'] as String).toLowerCase();
      _logger.d("values form  $val_form");

      final fileSelfie =
          (val_form["selfie"]?[0]) is File ? (val_form["selfie"]?[0]) : null;

      //String address = form.fields['address']!.value;
      final updated_user = _firebaseAuthenticationService.currentUser!
        ..address = Address(values: val_form);
      updated_user.phone = val_form['phone'];
      updated_user.dni = val_form['dni'];
      updated_user.fullName = (val_form['fullName'] as String).toLowerCase();
      updated_user.sex = val_form['sex'];

      //_logger("File selfie new $fileSelfie original ${updated_user.selfie.url}")

      if (fileSelfie != null) {
        await _firestoreService.updateUserWithImageSelfie(
            updated_user, fileSelfie);
      } else {
        await _firestoreService.updateUser(updated_user);
      }

      //_navigationService.replaceWith(Routes.startUpView);
      _navigationService.back();
    } catch (e) {
      _logger.d(e);
    }
  }
}
