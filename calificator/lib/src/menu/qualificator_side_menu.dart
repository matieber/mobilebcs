import 'package:calificator/src/user/user_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ui_model/custom_icon_text_button.dart';

class QualificationSideMenu extends StatefulWidget{

  final String serverUrl;

  const QualificationSideMenu(this.serverUrl,{Key? key}) : super(key: key);

  @override
  State<QualificationSideMenu> createState() => _QualificationSideMenuState(serverUrl);
}

class _QualificationSideMenuState extends State<QualificationSideMenu> {
  final String serverUrl;

  _QualificationSideMenuState(this.serverUrl);




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
              const Icon(Icons.logout),
              'Cerrar',
            voidCallback: (){
              Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context)=> UserPage(serverUrl))
                );
            },
          ),
        ],
      ),
    );
  }


}