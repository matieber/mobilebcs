
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget{

  final String text;
  final VoidCallback? voidFunction;

  const CustomTextButton(this.text,{this.voidFunction,Key? key}) : super(key: key);



  @override
  ElevatedButton build(BuildContext context) {
    return ElevatedButton(
        onPressed: voidFunction ?? (){},
        child: Text(text,style: TextStyle(
          fontSize: 30,
        ),
        textAlign: TextAlign.center),
        style: ElevatedButton.styleFrom(
            primary: Colors.green,
            fixedSize: const Size.fromHeight(150)
        )
    );
  }

}