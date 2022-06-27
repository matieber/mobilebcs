import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/app/app.router.dart';

import 'package:stacked/stacked.dart';
//import 'package:mercadosalud/services/firebase_authentication_service.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';

import 'package:mercadosalud/services/authentication_service.dart';

import 'package:stacked_services/stacked_services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mercadosalud/app/app.logger.dart';

class RecoverPassViewModel extends BaseViewModel {
  final _firebaseAuthenticationService = locator<AuthenticationService>();
  final _backendFirebaseAuthenticationService =
      locator<FirebaseAuthenticationService>();
  final _logger = getLogger('UI');
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();

  Future submitIfValid(FormBuilderState form) async {
    if (form.saveAndValidate()) {
      _logger.d("Valid data form");
      await submit(form);
    } else {
      _logger.d("Invalid data form");
    }
  }

  Future submit(FormBuilderState form) async {
    String targetEmail = form.fields['email']!.value;
    try {
      final dynamic sended = await runBusyFuture(runPasswordReset(targetEmail));
      final bool sended_b = sended;
      if (sended_b) {
        _bottomSheetService
            .showBottomSheet(
              title: 'message',
              description: "Se envió reset link a su casilla",
            )
            .whenComplete(() => navigateToLoginView());
      } else
        _bottomSheetService.showBottomSheet(
            title: 'error', description: "Ocurrió un error");
    } on Exception {
      _bottomSheetService.showBottomSheet(
          title: 'error', description: "Ocurrió un error");
    }
  }

  Future<dynamic> runPasswordReset(String targetEmail) =>
      _backendFirebaseAuthenticationService.sendResetPasswordLink(targetEmail);

  void navigateToLoginView() => _navigationService.navigateTo(Routes.loginView);
}
