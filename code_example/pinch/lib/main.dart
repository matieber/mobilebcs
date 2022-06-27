import 'package:apinch/welcome.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'locator_service.dart';
import 'login.dart';
import 'package:apinch/services/wifi/connectivity_status.dart';
import 'package:provider/provider.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'themes.dart';
import 'package:apinch/services/wifi/apinchwifi.dart';

import 'package:apinch/locator_service.dart' as di;

//void main() => runApp(MyApp());
void main() async {
  /*  WidgetsFlutterBinding.ensureInitialized() is required in Flutter v1.9.4+
 *  before using any plugins if the code is executed before runApp.*/

  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(
    EasyDynamicThemeWidget(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<ConnectivityStatus>(
      create: (context) =>
          //ConnectivityService().connectionStatusController.stream,
          di.sl<APinchConnectivityService>().connectionStatusController.stream,
      child: MaterialApp(
        title: 'APinch',
        theme: lightThemeData,
        darkTheme: darkThemeData,
        themeMode: EasyDynamicTheme.of(context).themeMode,
        home: Welcome(di.sl<APinchConnectivityService>()),
      ),
    );
  }

  static Future<bool> onBackPressed(BuildContext context){

      return showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: new Text(SplashConstants.backButtonMessage),
          content: new Text(SplashConstants.backButtonQuestion),
          actions: <Widget>[
            new GestureDetector(
              onTap: () => Navigator.of(context).pop(false),
              child: TextButton(child: Text(SplashConstants.backButtonNoAnswer),),
            ),
            SizedBox(height: 16),
            new GestureDetector(
              onTap: () => Navigator.of(context).pop(true),
              child: TextButton(child: Text(SplashConstants.backButtonYesAnswer),),
            ),
          ],
        ),
      ) ??
          false;
    }
}


/*
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<ConnectivityStatus>(
      create: (context) =>
          ConnectivityService().connectionStatusController.stream,
      child: MaterialApp(
        title: 'APinch',
        theme: ThemeData(
          brightness: Brightness.light,
          backgroundColor: Colors.black,
          cursorColor: Colors.amber,
          primaryColor: Colors.amber,
          accentColor: Color(0xFFf7d426),
          fontFamily: 'Hind',
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            bodyText2: TextStyle(fontSize: 18.0),
            bodyText1: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        ),
        home: Welcome(),
      ),
    );
  }
}
*/
