
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
import 'package:horizontal_picker/horizontal_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class QualifierPage extends StatefulWidget{

  final User user;
  final QualificationSideMenu _qualificationSideMenu;




  final QualifierJobClientHttp _client;

   QualifierPage(this.user,String serverUrl,{Key? key}):
         _client=QualifierJobClientHttp(serverUrl),
         _qualificationSideMenu=QualificationSideMenu(serverUrl,endSession: true,user: user,),
         super(key: key);



  @override
  State<QualifierPage> createState() => _QualifierPageState();
}

class _QualifierPageState extends State<QualifierPage> {

  String position = "";
  int? score;
  bool loading=false;
  String setCode="";



  ImageProvider? imageProvider;

  void _nextJob(BuildContext context) {
    setState(
            () {
          loading = true;
        });
    widget._client.nextJob(widget.user.username).then((value) =>
        setState(
                () {
                  loading=false;
                  if(value != null){
                    position = value.position.toString();
                    setCode=value.setId!;
                    if(value.byteImages.isNotEmpty) {
                      imageProvider=MemoryImage(value.byteImages.first);
                    }
                  }else{
                    position="";
                    score=null;
                    imageProvider=null;
                    showAlertDialog(context,"No hay nuevas caravanas");
                  }
              }
      )
    );
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        drawer: widget._qualificationSideMenu,
        appBar: buildAppBar(getTitle(),context),
        body:
        SizedBox(
    child:
        Column(
          children: [
            SafeArea(
              child:
              SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        HorizontalPicker(
                          minValue: 1,
                          maxValue: 5,
                          divisions: 4,
                          height: 100,
                          onChanged: (value) {
                            setState(()=>score=value.toInt());

                          },
                        ),

                      ]
                  )
              ),
            ),
            buildQualifyButton(),
            getImage(),


          ],
        )
        )
    );


  }

  CustomTextButton buildQualifyButton() {
    bool disabled=false;
    if(imageProvider==null){
      disabled=true;
    }
    return CustomTextButton("Calificar",
        voidFunction: () {
          widget._client.qualify(widget.user.username, setCode,score!);
          _nextJob(context);
        },
        height: 50,fontSize: 20,disabled: disabled);
  }

  Widget getImage() {
    if(loading){
        return LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.green,
          size: 200,
        );
    }else {
      return MyImage(imageProvider);
    }
  }

  String getTitle(){
   String title= getPositionText();
   if(title==""){
     title=widget.user.userType.value.capitalize()+" - "+widget.user.username+getPositionText();
   }
   return title;
  }

  AppBar buildAppBar(String title, BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.green,
      actions: actions(context),

    );
  }

  List<Widget> actions(BuildContext context) {

    var list = <Widget>[];
    var iconButton= IconButton(
      icon: getIcon(),
      onPressed: () {
        imageProvider=null;
        _nextJob(context);
      },
    );
    list.add(iconButton);
    return list;
  }

  Icon getIcon() {
    if(position!="") {
      return const Icon(Icons.skip_next,);
    }else{
      return const Icon(Icons.navigate_next,);

    }
  }

  String getPositionText() {
    if(position != ""){
      return "Posición ${position}";
    }else{
      return "";
    }
  }
  

}