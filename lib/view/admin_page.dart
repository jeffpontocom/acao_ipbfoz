//import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '/app_data.dart';
import '/utils/util.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with TickerProviderStateMixin {
  /* VARIAVEIS */

  /* METODOS */

  /* WIDGETS */
  Widget tituloSecao(titulo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        titulo,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget get listaDiaconos {
    List<String> ids = AppData.diaconos.keys.toList();
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true, // Obrigatorio (gera erro se falso)
      itemCount: AppData.diaconos.length,
      itemBuilder: (context, i) {
        return ListTile(
          leading: IconButton(
            icon: Hero(
              tag: ids[i],
              child: const Icon(Icons.person),
            ),
            onPressed: null,
          ),
          title: Text(AppData.diaconos[ids[i]]?.nome ?? '[Erro]'),
          subtitle: Text(AppData.diaconos[ids[i]]?.email ?? '[Erro]'),
          trailing: const IconButton(
            icon: Icon(Icons.phone),
            onPressed: null,
          ),
          onTap: () {
            Modular.to.pushNamed('/diacono?id=' + ids[i]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração do sistema'),
      ),
      body: Scrollbar(
        isAlwaysShown: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: 24,
            horizontal: Util.paddingListH(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              tituloSecao('Diáconos'),
              listaDiaconos,
              const Divider(),
              tituloSecao('Outras definições'),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
