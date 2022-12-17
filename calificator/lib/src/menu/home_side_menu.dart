import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ui_model/custom_exit_button.dart';
import '../ui_model/custom_icon_text_button.dart';

class HomeSideMenu extends StatefulWidget{



  HomeSideMenu({Key? key}) : super(key: key);

  @override
  State<HomeSideMenu> createState() => _HomeSideMenuState();
}

class _HomeSideMenuState extends State<HomeSideMenu> {

  static AppBar buildAppBar(String title) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.green,

    );
  }

  MaterialPageRoute buildSettingPage() {
    return MaterialPageRoute(builder:
        (context) => Scaffold(
          appBar: buildAppBar("Configuración"),
          body: Container(
            color: Colors.lightGreen.shade100,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CustomExitButton()
              ],
            ),
          ),
        )
    );
  }




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
              const Icon(Icons.settings),
              'Configuración',
            voidCallback: (){
              Navigator.of(context).pop();
                Navigator.of(context).push(buildSettingPage());
            },
          ),
        ],
      ),
    );
  }
}