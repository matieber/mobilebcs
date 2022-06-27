import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login.dart';
import 'constants.dart';
import 'package:apinch/services/wifi/apinchwifi.dart';
import 'package:apinch/services/wifi/connectivity_status.dart';
import 'package:provider/provider.dart';

class Welcome extends StatelessWidget {
  APinchConnectivityService aPinchConService;

  Welcome(this.aPinchConService);

  @override
  build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);

    return SplashScreen(
      seconds: 4,
      navigateAfterSeconds: new Login(),
      image: Image.asset(AppURLConstants.mainImageURL),
      backgroundColor: Colors.white,
      loaderColor: Theme.of(context).primaryColor,
      loadingText: Text(SplashConstants.mainSplashMsg),
      styleTextUnderTheLoader:
          TextStyle(fontSize: 8.0, color: Colors.grey[400]),
      photoSize: 100.0,
      onClick: () => Fluttertoast.showToast(
          msg:
              "Espere, la aplicación esta cargando y conectando a la red wifi de APinch",
          backgroundColor: Colors.black38,
          gravity: ToastGravity.BOTTOM,
          fontSize: 12.0,
          textColor: Colors.white,
          //timeInSecForIos: 1,
          toastLength: Toast.LENGTH_SHORT),
    );
  }
}
