import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class ConnectivityService {
  StreamController<ConnectivityResult> connectionStatusController =
      StreamController<ConnectivityResult>();

  final DialogService _dialogService = locator<DialogService>();

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final _logger = getLogger('ConnectivityService');
  late ConnectivityResult _connectivity;

  ConnectivityResult get connectivity => _connectivity;

  ConnectivityService() {

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      _logger.d("Connectivity status dispatched: $result");

      _connectivity = result;
      connectionStatusController.add(_connectivity);

      if (result == ConnectivityResult.none) {
        _dialogNoConnectivity();
      }
    });
  }

  Future<void> checkConnectivity() async {
    try {
      _connectivity = await Connectivity().checkConnectivity();
      if (_connectivity == ConnectivityResult.none)
        await _dialogNoConnectivity();
    } catch (e) {
      _logger.d(e);
    }
  }

  Future<void> _dialogNoConnectivity() async {
    while (_connectivity == ConnectivityResult.none)
      await _dialogService.showDialog(
        title: "Problemas de Conectividad",
        description: "Conecte red de datos o wifi",
      );
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }
}
