import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/app/app.router.dart';

import 'package:stacked/stacked.dart';
//import 'package:mercadosalud/services/firebase_authentication_service.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';

import 'package:mercadosalud/services/authentication_service.dart';

import 'package:stacked_services/stacked_services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:mercadosalud/app/app.logger.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';

class LoginViewModel extends BaseViewModel {
  final _firebaseAuthenticationService = locator<AuthenticationService>();
  final _logger = getLogger('LoginViewModel');

  final _navigationService = locator<NavigationService>();
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
    final FirebaseAuthenticationResult? result =
        await runBusyFuture(runAuthentication(form));
    _handleAuthenticationResponse(result!);
  }

  void _handleAuthenticationResponse(FirebaseAuthenticationResult authResult) {
    if (!authResult.hasError) {
      // navigate to success route
      _navigationService.replaceWith(Routes.startUpView);
    } else {
      _bottomSheetService.showBottomSheet(
          title: 'error', description: LocaleKeys.API_cannot_login.tr());
    }
  }

  Future<FirebaseAuthenticationResult?> runAuthentication(
          FormBuilderState form) =>
      _firebaseAuthenticationService.loginWithEmail(
        email: form.fields['email']!.value,
        password: form.fields['password']!.value,
      );

  Future<void> useGoogleAuthentication() async {
    final FirebaseAuthenticationResult result =
        await _firebaseAuthenticationService.signInWithGoogle();
    _handleAuthenticationResponse(result);
  }

  void navigateBack() => _navigationService.back();

  void navigateToCreateAccount() =>
      _navigationService.navigateTo(Routes.createAccountView);

  void navigateTorecoverPass() =>
      _navigationService.navigateTo(Routes.recoverPassView);
}
