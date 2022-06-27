import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:mercadosalud/app/app.router.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

import 'drawer_viewmodel.dart';

class MainDrawerView extends StatelessWidget {
  MainDrawerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MainDrawerViewModel>.reactive(
      builder: (context, model, child) => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(LocaleKeys.UI_DrawerView_titulo).tr(),
              decoration: BoxDecoration(
                  color: Colors.green,
                  image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage('assets/images/ms.splash.png'))),
            ),
            ListTile(
              title: Text(LocaleKeys.UI_DrawerView_hogar).tr(),
              leading: Icon(Icons.home),
              onTap: () {
                model.navigateTo(Routes.homeView);
              },
            ),
            ListTile(
              title: Text(LocaleKeys.UI_DrawerView_direccion).tr(),
              leading: Icon(Icons.person),
              onTap: () {
                model.navigateTo(Routes.addressSelectionView);
              },
            ),
            ListTile(
              title: Text(LocaleKeys.UI_DrawerView_personasACargo).tr(),
              leading: Icon(Icons.people),
              onTap: () {
                model.navigateTo(Routes.familtyView);
              },
            ),
            ListTile(
              title: Text(LocaleKeys.UI_DrawerView_favoritos).tr(),
              leading: Icon(Icons.health_and_safety_outlined),
              onTap: () {
                model.navigateTo(Routes.favouriteView);
              },
            ),
            ListTile(
              title: Text(LocaleKeys.UI_DrawerView_salir).tr(),
              leading: Icon(Icons.exit_to_app),
              onTap: () {
                model.confirmedLogOut();
              },
            ),
          ],
        ),
      ),
      viewModelBuilder: () => MainDrawerViewModel(),
    );
  }
}
