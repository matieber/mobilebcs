
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget{

  final String text;
  final VoidCallback? voidFunction;
  final double height;
  final double fontSize;
  final bool disabled;
  const CustomTextButton(this.text,{this.voidFunction, this.height=150,this.fontSize=30, this.disabled=false,Key? key}) : super(key: key);



  @override
  ElevatedButton build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed(),
        child: Text(text,style: TextStyle(
          fontSize: fontSize,
        ),
        textAlign: TextAlign.center),
        style: ElevatedButton.styleFrom(
            primary: Colors.green,
            fixedSize:  Size.fromHeight(height)
        )
    );
  }

  Function()? onPressed() {
    if(!disabled) {
      return voidFunction ?? () {};
    }else{
      return null;
    }
  }

}