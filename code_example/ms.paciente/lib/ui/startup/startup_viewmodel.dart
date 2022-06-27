import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mercadosalud/services/authentication_service.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:mercadosalud/services/price_service.dart';
import 'package:mercadosalud/services/connectivity_service.dart';
import 'package:mercadosalud/services/email_service.dart';

// "BUSINESS LOGIC" AND VIEW STATE

class StartUpViewModel extends BaseViewModel {
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final _nagivationService = locator<NavigationService>();
  final _emailService = locator<EmailService>();
  final _priceService = locator<
      PriceService>(); //hace que se carguen los precios al inicio

  final _logger = getLogger('StartUpViewModel');

  bool get hasUser => _authenticationService.currentUser != null;

  bool get hasAddress => _authenticationService.currentUser!.hasAddress;

  bool get isEnabled => _authenticationService.currentUser?.enabled ?? false;

  Future runStartUpLogic() async {
    setBusy(true);

    _logger.d("RUN ");

    final _connectivityService = locator<ConnectivityService>();
    await _connectivityService.checkConnectivity();

    var hasLoggedInUser = await _authenticationService.isUserLoggedIn();

    if (hasLoggedInUser) {
      _logger.d("user logged: $hasLoggedInUser");
      final _currentUser = _authenticationService.currentUser!;
      final enabled = _currentUser.enabled ?? false;
      if (enabled) {
        await _priceService.initialize();
        setBusy(false);
        //verifica si el perfil esta completo
        while (!_authenticationService.currentUser!.hasAddress) {
          await _nagivationService.navigateTo(Routes.addressSelectionView);
        }
        // navigate to home view si el perfil esta completo
        _nagivationService.replaceWith(Routes.homeView);
      } else {
        //desactivado
        setBusy(false);

        await Future.delayed(const Duration(seconds: 5), () {});
        await _logOut();
      }
    } else {
      //no esta logeado
      _logger.d('No user on disk, navigate to the LoginView');
      _nagivationService.replaceWith(Routes.loginView);
    }
  }

  Future<void> _logOut() async {
    try {
      await _authenticationService.logout();
      await _nagivationService.replaceWith(Routes.loginView);
    } catch (e) {
    }
  }
}
