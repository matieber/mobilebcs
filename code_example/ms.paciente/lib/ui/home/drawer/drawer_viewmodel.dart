import 'package:mercadosalud/app/app.locator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:mercadosalud/app/app.router.dart';
import 'package:mercadosalud/services/authentication_service.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class MainDrawerViewModel extends BaseViewModel {
  final _logger = getLogger('MainDrawerViewModel');
  final _navigationService = locator<NavigationService>();
  final _firebaseAuthenticationService = locator<AuthenticationService>();

  final DialogService _dialogService = locator<DialogService>();

  void navigateTo(String page) async {
    _navigationService.navigateTo(page);
  }

  Future<void> confirmedLogOut() async {
    var dialogResponse = await _dialogService.showConfirmationDialog(
      title: LocaleKeys.UI_Shared_seguro.tr(),
      description: LocaleKeys.UI_Shared_logout.tr(),
      confirmationTitle: LocaleKeys.UI_Shared_yes.tr(),
      cancelTitle: LocaleKeys.UI_Shared_no.tr(),
    );

    if (dialogResponse!.confirmed) {
      runBusyFuture(_logOut());
    }
  }

  Future<void> _logOut() async {
    try {
      await _firebaseAuthenticationService.logout();
      await _navigationService.replaceWith(Routes.loginView);
    } catch (e) {
    }
  }
}
