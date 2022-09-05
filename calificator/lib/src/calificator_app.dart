import 'dart:convert';

import 'package:calificator/src/qualifier/qualifier.dart';
import 'package:calificator/src/qualifier/qualifierClient.dart';
import 'package:calificator/src/user/userClient.dart';
import 'package:calificator/src/current_page.dart';
import 'package:calificator/src/menu/side_menu.dart';
import 'package:calificator/src/ui_model/custom_exit_button.dart';
import 'package:calificator/src/ui_model/custom_text_button.dart';
import 'package:calificator/src/user/login_user.dart';
import 'package:calificator/src/user/register_user.dart';
import 'package:calificator/src/user/user.dart';
import 'package:calificator/src/user/user_page.dart';
import 'package:flutter/material.dart';
/// The Widget that configures your application.
class CalificatorApp extends StatefulWidget {

  const CalificatorApp({Key? key}) : super(key: key);


  
  @override
  State<CalificatorApp> createState() => _CalificatorAppState();
}

class _CalificatorAppState extends State<CalificatorApp> {

  int _currentIndex=0;

  late CurrentPage _currentPage;

  double _width = 0;
  double _height = 0;
  String _serverIp="";
  int _serverPort=0;
  User user=User();
  String _title = 'Calificador';






  @override
  Widget build(BuildContext context) {

    DefaultAssetBundle.of(context).loadString('assets/my_config.json')
        .then((jsonString){
        dynamic jsonMap=jsonDecode(jsonString);
        _serverIp=jsonMap['serverIp'];
        _serverPort=jsonMap['serverPort'];
      }
    );



    _currentPage=CurrentPage(
        (){changePage(0,'Calificador');},
        (){changePage(1,'Calificador - Configuración');},
        (){changePage(2,'Calificador - Ingresar usuario');},
        (){changePage(3,'Calificador - Registrar usuario');},
        (){changePage(4,'Calificador');}

    );
    return  Scaffold(
                appBar: buildAppBar(),
                drawer: SideMenu(_currentPage),
                body:
                _width == 0 && _serverIp== "" && _serverPort==0 ?
                buildLoading(): buildBody()
    );
  }

  void changePage(int index,String title){
    setState(() {
      _currentIndex=index;
      _title=title;
    });
  }




  Container buildLoading() {
    getWidth(context).then((double value) => setState(
        () {
          _width = value;

        }
    ));
    getHeight(context).then((double value) => setState(
            () {
          _height = value;

        }
    ));
    return Container(
        child: Center(
          child: Text("Cargando..."),
        ),
      );
  }
  
  Future<double> getWidth(BuildContext context) async {
    await MediaQuery.of(context).size.width > 0;
    print('Obtenido '+MediaQuery.of(context).size.width.toString());
    return MediaQuery.of(context).size.width;
  }

  Future<double> getHeight(BuildContext context) async {
    await MediaQuery.of(context).size.height > 0;
    print('Obtenido '+MediaQuery.of(context).size.height.toString());
    return MediaQuery.of(context).size.height;
  }



  Center buildBody() {
    return Center(
        child: getChild()
    );
  }

  Widget buildSettingPage(){
    return Container(
      color: Colors.lightGreen.shade100,
      width: double.infinity,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CustomTextButton('Finalizar sesión'),
            CustomExitButton()
           ],
      ),
    );
  }


  AppBar buildAppBar() {
    return AppBar(
        title: Text(_title),
        backgroundColor: Colors.green,

      );
  }

  Widget getChild() {
    Widget child;
    switch(_currentIndex){
      case 0:
        child=UserPage(_width,_height,_currentPage);
        break;
      case 1:
        child= buildSettingPage();
        break;
      case 2:
        child= LoginUser(_width,UserHttp(_serverIp,_serverPort),_currentPage,user);
        break;
      case 3:
        child= RegisterUser(_width);
        break;
      case 4:
        {
          child = Qualifier(QualifierHttp(_serverIp, _serverPort), user);
          break;
        }
      default:
        throw Exception('Invalid index page');
    }
    return child;
  }

}
