import 'package:apinch/constants.dart';
import 'package:apinch/services/connectionHandler.dart';
import 'package:apinch/tabs/adverts.dart';
import 'package:apinch/tabs/network.dart';
import 'package:apinch/tabs/credit.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:apinch/services/wifi/apinchwifi.dart';
import 'package:apinch/locator_service.dart' as di;
import 'package:logger/logger.dart';

import 'main.dart';

class MainMenu extends StatefulWidget {
  final VoidCallback signOut;
  ConnectionHandler connHandler;
  APinchConnectivityService aPinchConService;

  MainMenu(this.signOut) {
    connHandler = di.sl<ConnectionHandler>();
    aPinchConService = di.sl<APinchConnectivityService>();

    connHandler.startsNavigation();
  }

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  _MainMenuState();

  signOut() {
    setState(() {
      widget.aPinchConService.disconnect();
      widget.signOut();
    });
  }

  changeTheme() {
    setState(() {
      bool isDarkModeOn = Theme.of(context).brightness == Brightness.dark;
      print("theme $isDarkModeOn");
      EasyDynamicTheme.of(context).changeTheme(dark: !isDarkModeOn);
    });
  }

  int currentIndex = 0;

  String email = "", name = "";
  PageController _homePageController;
  List<String> _pages_apptitle = [
    "Redes WiFi",
    "Tu crédito",
    "Anuncios Publicitarios"
  ];
  List<Widget> _pages;

  void _onPageChanged(int index) {}

  void goToAdvertsPage() {
    setState(() {
      currentIndex = 2;
      _homePageController.jumpToPage(currentIndex);
    });
  }

  void goCreditPage() {
    setState(() {
      currentIndex = 1;
      _homePageController.jumpToPage(currentIndex);
    });
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      email = preferences.getString("email");
      name = preferences.getString("full_name");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
    _homePageController = PageController();
    _pages = [
      NetworksPage(widget.aPinchConService),
      CreditPage(goToAdvertsPage: goToAdvertsPage),
      AdvertsPage(goToCreditPage: goCreditPage)
    ];
  }

  @override
  Widget build(BuildContext context) {
    final logger = di.sl<Logger>();

    return WillPopScope(
      onWillPop: () => MyApp.onBackPressed(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            _pages_apptitle[currentIndex],
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                signOut();
              },
              icon: Icon(Icons.lock_open),
            ),
            /*IconButton(
              onPressed: () {
                changeTheme();
              },
              icon: Icon(Icons.preview),
            )*/
          ],
        ),
        body: PageView(
            controller: _homePageController,
            children: _pages,
            onPageChanged: _onPageChanged,
            physics: NeverScrollableScrollPhysics()),
        bottomNavigationBar: BottomNavyBar(
          backgroundColor: Colors.black,
          iconSize: 30.0,
//        iconSize: MediaQuery.of(context).size.height * .60,
          selectedIndex: currentIndex,
          onItemSelected: (index) {
            logger.d('selected tab $index');
            setState(() {
              currentIndex = index;

              final timeok = widget.aPinchConService.stopResetWatchAd();
              _homePageController.jumpToPage(index);
            });
          },

          items: [
            BottomNavyBarItem(
                icon: Icon(Icons.wifi),
                title: Text('Redes'),
                activeColor: Theme.of(context).accentColor),
            BottomNavyBarItem(
                icon: Icon(Icons.attach_money),
                title: Text('Crédito'),
                activeColor: Theme.of(context).accentColor),
            BottomNavyBarItem(
                icon: Icon(Icons.web),
                title: Text('Anuncios'),
                activeColor: Theme.of(context).accentColor),
          ],
        ),
      ),
    );
  }
}
