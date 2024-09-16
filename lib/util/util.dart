import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import "package:flutter/material.dart";

showAlert(BuildContext context, String body,
    {String? title = "", Function? callback}) {
  // set up the buttons

  Widget continueButton = TextButton(
    child: const Text("Ok"),
    onPressed: () {
      Navigator.of(context).pop();
      if (callback != null) {
        callback();
      }
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    // icon: Icon(Icons.info),
    content: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text(
          body,
          style: TextStyle(fontSize: 16),
        )),
    actions: [
      continueButton,
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
