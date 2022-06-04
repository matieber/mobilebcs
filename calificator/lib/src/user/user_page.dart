
import 'package:calificator/src/current_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ui_model/custom_text_button.dart';
import '../ui_model/icon_button.dart';
import '../ui_model/input_text.dart';



class UserPage extends StatelessWidget{


  final CurrentPage currentPage;
  final double _width;
  final double _height;

  const UserPage(this._width,this._height,this.currentPage,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightGreen.shade100,
      width: double.infinity,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Container(
            width: _width/2,
            height: _height/4,
            child: CustomTextButton('Ingresar usuario',voidFunction: (){_toLoginUser();})
          ),
            Container(
                width: _width/2,
                height: _height/8,
            ),
          Container(
            width: _width/2,
            height: _height/4,
            child: CustomTextButton('Registrar usuario',voidFunction: (){_toRegisterUser();})
          )
    ]

      ),
    );
  }

 void _toLoginUser(){
    currentPage.toLoginUser();
 }

 void _toRegisterUser(){
    currentPage.toRegisterUser();
 }
}
