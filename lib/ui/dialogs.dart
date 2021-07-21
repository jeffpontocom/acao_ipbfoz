import 'package:flutter/material.dart';

showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: new Row(
      children: [
        CircularProgressIndicator(),
        Container(
            margin: EdgeInsets.only(left: 7), child: Text("Carregando...")),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

AlertDialog dialogConfirmaAcao(context) {
  return AlertDialog(
    content: new Row(
      children: [
        Container(
            margin: EdgeInsets.only(left: 7),
            child: Text("Deseja excluir esse item?")),
      ],
    ),
    actions: <Widget>[
      TextButton(
        child: Text('OK'),
        onPressed: () {
          Navigator.pop(context, true);
        },
      ),
    ],
  );
}
