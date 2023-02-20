import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showAlertDialog(BuildContext context,String message) {

  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();

    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}