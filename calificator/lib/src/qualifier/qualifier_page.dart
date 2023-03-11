
import 'package:calificator/src/qualifier/qualifier_job_client.dart';
import 'package:calificator/src/user/user.dart';
import 'package:calificator/src/user/user_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:calificator/src/ui_model/extension.dart';
import '../menu/qualificator_side_menu.dart';
import '../ui_model/alert.dart';
import '../ui_model/custom_text_button.dart';
import 'image.dart';


class QualifierPage extends StatefulWidget{

  final User user;




  final QualifierJobClientHttp _client;

   QualifierPage(this.user,String serverUrl,{Key? key}):
         _client=QualifierJobClientHttp(serverUrl),super(key: key);


  @override
  State<QualifierPage> createState() => _QualifierPageState();
}

class _QualifierPageState extends State<QualifierPage> {

  int position = -1;

  ImageProvider? imageProvider;

  void _nextJob(BuildContext context) {
    widget._client.nextJob(widget.user.username).then((value) =>
        setState(
                () {
                  if(value != null){
                    position = value.position;
                    if(value.byteImages.isNotEmpty) {
                      imageProvider=MemoryImage(value.byteImages.first);
                    }
                  }else{
                    showAlertDialog(context,"No hay nuevas caravanas");
                  }
              }
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(widget.user.userType.value.capitalize()+" - "+widget.user.username),
        body:  Column(
          children: [
            Text(position.toString()),
            MyImage(imageProvider),
            CustomTextButton(
              "Siguiente",
              voidFunction: () => _nextJob(context),)


          ],
        )
    );


  }

  AppBar buildAppBar(String title) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.green,

    );
  }

}