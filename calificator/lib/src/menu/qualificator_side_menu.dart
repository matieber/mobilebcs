import 'package:calificator/src/user/user_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../qualifier/qualification_session_http.dart';
import '../qualifier/qualifier_session_page.dart';
import '../ui_model/alert.dart';
import '../ui_model/custom_icon_text_button.dart';
import '../ui_model/custom_text_button.dart';
import '../user/user.dart';

class QualificationSideMenu extends StatefulWidget{

  final String serverUrl;

  final bool endSession;
  final User? user;
  const QualificationSideMenu(this.serverUrl,{Key? key,this.endSession=false,this.user}) : super(key: key);

  @override
  State<QualificationSideMenu> createState() => _QualificationSideMenuState();
}

class _QualificationSideMenuState extends State<QualificationSideMenu> {


  _QualificationSideMenuState();




  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: children(context),
      ),
    );
  }

  List<Widget> children(BuildContext context) {
    var list = [
        buildDrawerHeader(),
        closeButton(context),
      ];
    if(widget.endSession){
      list.add( endSession(context));
    }
    return list;
  }

  DrawerHeader buildDrawerHeader() {
    return const DrawerHeader(
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
        );
  }

  CustomIconTextButton closeButton(BuildContext context) {
    return CustomIconTextButton(
            const Icon(Icons.logout),
            'Cerrar',
          voidCallback: (){
            Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context)=> UserPage(widget.serverUrl))
              );
          },
        );
  }

  CustomIconTextButton endSession(BuildContext context) {
      return CustomIconTextButton(
          const Icon(Icons.close),
          'Finalizar sesión de calificación',
          voidCallback: () {
            Future<void> future = _endQualificationSession(context, widget.serverUrl);
            future
            .then((value) =>
                Navigator.of(context).pop()
            )
            .then((value) => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder:
                    (context) {
                  return QualifierSessionPage(widget.serverUrl,widget.user!);
                }
                )
            ))
                .onError((error, stackTrace) =>
                showAlertDialog(context, error.toString()));
          });
    
  }

  Future<void> _endQualificationSession(BuildContext context,String serverUrl) {
    var client=QualificationSessionHttp(serverUrl);
    return client.endSession("DEFAULT");
  }


}