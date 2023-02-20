
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../menu/home_side_menu.dart';
import '../ui_model/custom_text_button.dart';
import 'package:calificator/src/user/login_user.dart';
import 'package:calificator/src/user/register_user.dart';


class UserPage extends StatelessWidget{


  final String serverUrl;

  UserPage(this.serverUrl,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var registerUser = RegisterUser(serverUrl);
    return Scaffold(
      appBar: buildAppBar(),
      drawer: HomeSideMenu(),
      body: Container(
      color: Colors.lightGreen.shade100,
      width: double.infinity,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Container(

            child: CustomTextButton('Ingresar usuario',voidFunction: (){_toLoginUser(context,serverUrl);})
          ),
            const SizedBox(height: 100),
          Container(
            child: CustomTextButton('Registrar usuario',voidFunction: (){

_toRegisterUser(context,registerUser);})
          )
    ]

      ),
    )
    );
  }

 void _toLoginUser(BuildContext context,String serverUrl){

   Navigator.of(context)
       .push(LoginUser(serverUrl));
  }

 void _toRegisterUser(BuildContext context, RegisterUser registerUser){
   Navigator.of(context)
       .push(MaterialPageRoute(builder: (context)=> registerUser ));
 }

  static AppBar buildAppBar() {
    return AppBar(
      title: Text('Calificador'),
      backgroundColor: Colors.green,

    );
  }
}
