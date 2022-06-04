
import 'package:calificator/src/ui_model/icon_button.dart';
import 'package:flutter/material.dart';

class UserNameInputText extends StatefulWidget{


  final double width;
  final ValueChanged<String> onSubmitted;

  final labelText;


  const UserNameInputText(this.width,this.labelText,this.onSubmitted,{Key? key}) : super(key: key);



  @override
  State<UserNameInputText> createState() => _UserNameInputTextState();


}

class _UserNameInputTextState extends State<UserNameInputText> {

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
      return
        SizedBox(
            width: widget.width/2,
            child:
            TextField(
              controller: _controller,
              onSubmitted: widget.onSubmitted,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                labelText: widget.labelText,
                suffixIcon: CustomIconButton(const Icon(Icons.navigate_next),onPressed: () => widget.onSubmitted(_controller.value.text),)
              ),

            ),
        );
  }
}