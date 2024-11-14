
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomIconTextButton extends StatefulWidget{

  final Icon icon;
  final String text;
  final VoidCallback? voidCallback;

  const CustomIconTextButton(this.icon,this.text,{this.voidCallback,Key? key}) : super(key: key);

  @override
  State<CustomIconTextButton> createState() => _CustomIconTextButtonState();
}

class _CustomIconTextButtonState extends State<CustomIconTextButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: widget.icon,
      label: Text(widget.text),
      onPressed: this.widget.voidCallback?? () {},
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green
        )
    );
  }
}