import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/app_data.dart';
import '/models/diacono.dart';
import '/ui/estilos.dart';

class DiaconoPage extends StatefulWidget {
  final String diaconoId;

  const DiaconoPage({Key? key, required this.diaconoId}) : super(key: key);

  @override
  _DiaconoPageState createState() => _DiaconoPageState();
}

class _DiaconoPageState extends State<DiaconoPage> {
  late Diacono mDiacono;

  @override
  void initState() {
    mDiacono = AppData.diaconos[widget.diaconoId] ?? Diacono();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Diácono'),
        titleSpacing: 0,
      ),
      body: mDiacono.email == null
          ? const Center(
              child: Text('Informações não encontradas!'),
            )
          : InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  Hero(
                    tag: widget.diaconoId,
                    child: const Icon(
                      Icons.account_circle,
                      size: 128.0,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    mDiacono.email ?? '[ERRO]',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 24.0),
                  TextFormField(
                    initialValue: mDiacono.nome,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      mDiacono.nome = value;
                    },
                    decoration: mTextFieldDecoration.copyWith(
                        labelText: 'Nome completo'),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    initialValue:
                        maskPhone.getMaskedString(mDiacono.telefone.toString()),
                    inputFormatters: [inputPhone],
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      mDiacono.telefone = int.parse(maskPhone.clearMask(value));
                    },
                    decoration:
                        mTextFieldDecoration.copyWith(labelText: 'Whatsapp'),
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: OutlinedButton.icon(
                          label: const Text('Sair'),
                          icon: const Icon(Icons.logout_rounded),
                          style: OutlinedButton.styleFrom(
                                  primary: Colors.white,
                                  backgroundColor: Colors.red)
                              .merge(mOutlinedButtonStyle),
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/login', (route) => false);
                          },
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: SizedBox(width: 12.0),
                      ),
                      Expanded(
                        flex: 4,
                        child: OutlinedButton.icon(
                          label: const Text('Atualizar dados'),
                          icon: const Icon(Icons.save_rounded),
                          style: mOutlinedButtonStyle,
                          onPressed: () {
                            _gravar();
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
    );
  }

  void _gravar() async {
    // Abre circulo de progresso
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {
      FirebaseFirestore.instance
          .collection('diaconos')
          .doc(mDiacono.uid)
          .set(mDiacono.toJson())
          .then((value) => Navigator.pop(context))
          .catchError((error) => dev.log("Falha ao adicionar diacono: $error",
              name: 'DiaconoPage'));
    } catch (e) {
      dev.log(e.toString(), name: 'DiaconoPage');
    }
    Navigator.pop(context);
  }
}
