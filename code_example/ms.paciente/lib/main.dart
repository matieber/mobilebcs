import 'package:mercadosalud/ui/startup/startup_view.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'app/app.locator.dart';
import 'app/app.router.dart';
import 'package:flamingo/flamingo.dart';

import 'dart:io' show Platform;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp();
  await Flamingo.initializeApp();

  setupLocator();

  runApp(EasyLocalization(
      child: MyApp(),
      supportedLocales: [
        Locale('es', 'ES'),
      ],
      path: 'resources/langs',
      fallbackLocale: Locale('es', 'ES')));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: _add_form_loc(context.localizationDelegates),
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'Mercado Salud Paciente',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.green[500],
          accentColor: Colors.green[700],
          backgroundColor: Colors.grey[50],
          primarySwatch: Colors.blue,

          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 10.0,
            ),
            fillColor: Colors.grey[100],
            filled: true,
            labelStyle: TextStyle(color: Colors.blueGrey),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26),
                borderRadius: BorderRadius.circular(10)),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: TextTheme(
            subtitle1: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.black),
            bodyText2: TextStyle(
                fontSize: 13.0,
                //fontWeight: FontWeight.bold,
                color: Colors.black87),

            headline6: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
        ),
        navigatorKey: StackedService.navigatorKey,
        onGenerateRoute: StackedRouter().onGenerateRoute,
        home: StartUpView());
  }

  _add_form_loc(List<LocalizationsDelegate> localizationDelegates) {
    localizationDelegates.add(FormBuilderLocalizations.delegate);
    return localizationDelegates;
  }
}
