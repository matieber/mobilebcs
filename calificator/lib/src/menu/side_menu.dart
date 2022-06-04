import 'package:calificator/src/current_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ui_model/custom_icon_text_button.dart';

class SideMenu extends StatefulWidget{


  CurrentPage currentPage;

  SideMenu(this.currentPage,{Key? key}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState(currentPage);
}

class _SideMenuState extends State<SideMenu> {

  CurrentPage currentPage;

  _SideMenuState(this.currentPage);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
              decoration: BoxDecoration(

              ),
              child:
              Center(
                child: Text('Menú',
                  style: TextStyle(
                    fontSize: 30.0,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.lightGreen,
                        offset: Offset(5.0, 5.0),
                      ),
                    ],
                  ),
                ),
              )
          ),
          CustomIconTextButton(
              const Icon(Icons.home),
              'Inicio',
              voidCallback: (){
                setState(() {
                  currentPage.toHome();
                });
                Navigator.of(context).pop();
              },
            ),
          CustomIconTextButton(
              const Icon(Icons.settings),
              'Configuración',
            voidCallback: (){
              setState(() {
                currentPage.toSetting();
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}