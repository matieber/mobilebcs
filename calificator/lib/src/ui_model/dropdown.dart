import 'package:flutter/material.dart';

class CustomDropdownButton extends StatefulWidget {
  final List<CustomDropdownText> list;
  CustomDropdownText? previousDropDownValue;
  CustomDropdownText dropDownValue;
  Function notifyChange;

  CustomDropdownButton(this.list,this.notifyChange, {Key? key}):dropDownValue=list.first, super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomDropdownButtonState();

  String getValue() {
    return dropDownValue.value;
  }
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {


  _CustomDropdownButtonState();

  @override
  Widget build(BuildContext context) {
    return DropdownButton<CustomDropdownText>(
      value: widget.dropDownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (CustomDropdownText? value) {
        // This is called when the user selects an item.
        setState(() {
          widget.previousDropDownValue=widget.dropDownValue;
          widget.dropDownValue = value!;
          if(widget.dropDownValue!=widget.previousDropDownValue){
            widget.notifyChange();
          }
        });
      },
      items: widget.list.map<DropdownMenuItem<CustomDropdownText>>((CustomDropdownText value) {
        return DropdownMenuItem<CustomDropdownText>(
          value: value,
          child: Text(value.text),
        );
      }).toList(),
    );
  }
}

class CustomDropdownText{

  String value;

  String text;

  CustomDropdownText(this.value, this.text);
}