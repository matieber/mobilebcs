import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/app/app.router.dart';
import 'package:mercadosalud/ui/base/authentication_viewmodel.dart';
//import 'package:stacked_firebase_auth/src/firebase_authentication_service.dart';
//import 'package:mercadosalud/services/firebase_authentication_service.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'package:mercadosalud/services/authentication_service.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/app/app.logger.dart';

class CreateAccountViewModel extends BaseViewModel {
  final _firebaseAuthenticationService = locator<AuthenticationService>();
  final navigationService = locator<NavigationService>();
  final _logger = getLogger('UI');
  final _bottomSheetService = locator<BottomSheetService>();

  bool _showPassword = false;
  bool showPassword() => _showPassword;

  void tooglePassword() {
    _showPassword = !_showPassword;
    this.notifyListeners();
  }

  Future submitIfValid(FormBuilderState form) async {
    if (form.saveAndValidate()) {
      _logger.d("Valid data form");
      await submit(form);
    } else {
      _logger.d("Invalid data form");
    }
  }

  Future submit(FormBuilderState form) async {
    final result = await runBusyFuture(runAuthentication(form));
    _logger.d("create account res $result");
    if (!result!.hasError) {
      // navigate to success route
      //navigationService.back();
      navigationService.replaceWith(Routes.loginView);
    } else {
      _bottomSheetService.showBottomSheet(
          title: 'error', description: result.errorMessage);
    }
  }

//  Future<FirebaseAuthenticationResult> runAuthentication() =>
  Future<FirebaseAuthenticationResult?> runAuthentication(
          FormBuilderState form) =>
      _firebaseAuthenticationService.createAccountWithEmail(
        email: form.fields['email']!.value,
        password: form.fields['password']!.value,
      );

  void navigateBack() => navigationService.back();
}
