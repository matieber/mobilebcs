
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'custom_text_button.dart';

class CustomExitButton extends StatelessWidget{

  const CustomExitButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextButton('Salir', voidFunction: (){exitApp();});
  }

  exitApp(){
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }
}