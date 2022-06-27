import 'package:apinch/services/connectionHandler.dart';
import 'package:apinch/services/creditService.dart';
import 'package:apinch/services/wifi/apinchwifi.dart';
import 'package:apinch/services/ssl/ssl.dart';
import 'package:apinch/login.dart';
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerSingleton<CreditUpdater>(CreditUpdater());
  sl.registerSingleton<ConnectionHandler>(ConnectionHandler());
  sl.registerSingleton<Login>(Login());
  sl.registerSingleton<APinchSSLService>(APinchSSLService());
  sl.registerSingleton<Logger>(Logger(
    printer: PrettyPrinter(),
  ));
  sl.registerSingleton<APinchConnectivityService>(
      APinchConnectivityService(sl<ConnectionHandler>()));
}
