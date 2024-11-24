import 'package:flutter/material.dart';

import 'src/calificator_app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  final settingsController = SettingsController(SettingsService());

  await settingsController.loadSettings();


  runApp(
      MaterialApp(
        home: SafeArea(
            child: CalificatorApp()
        ),
        debugShowCheckedModeBanner: false,
      ));

}
