
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget{
  
  final Icon icon;
  final VoidCallback? onPressed;
  
  const CustomIconButton(this.icon,{this.onPressed,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed:onPressed ?? (){},
        child: icon,
        style: ElevatedButton.styleFrom(
            primary: Colors.green,
            fixedSize: const Size.fromWidth(50)
        )
    );
  }
  
}