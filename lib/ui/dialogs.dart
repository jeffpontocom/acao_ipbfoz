import 'package:flutter/material.dart';

showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        const CircularProgressIndicator(),
        Container(
          margin: const EdgeInsets.only(left: 7),
          child: const Text("Carregando..."),
        ),
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
    content: Row(
      children: [
        Container(
            margin: const EdgeInsets.only(left: 7),
            child: const Text("Deseja excluir esse item?")),
      ],
    ),
    actions: [
      TextButton(
        child: const Text('OK'),
        onPressed: () {
          Navigator.pop(context, true);
        },
      ),
    ],
  );
}
