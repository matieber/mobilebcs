import 'package:calificator/src/qualifier/qualifierClient.dart';
import 'package:calificator/src/user/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:calificator/src/current_page.dart';

class Qualifier extends StatefulWidget{

  int _position=0;
  final QualifierHttp _client;
  final User user;

  Qualifier(this._client,this.user);

  @override
  State<Qualifier> createState() => _QualifierState();
}

class _QualifierState extends State<Qualifier> {



  @override
  Widget build(BuildContext context) {
    
    return Column(
      children: [
        Text(widget._position.toString()),

      ],
    );
  }

  _QualifierState(){
    const duration = Duration(seconds: 10);


    Timer.periodic(duration, (Timer timer) {
      widget._client.nextJob(widget.user.username.toString()).then((response) => {
        if(response!=null && response.isNotEmpty){
          setState(() {
            if(response.containsKey("position")){
              widget._position=response.remove("position");
            }
          })
        }
      });
      /*setState(() {
        widget._position++;
        print(widget.user.username.toString()+" "+widget._position.toString());
      });*/

    });
  }
}
