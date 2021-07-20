import '../models/diacono.dart';
import '../ui/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DiaconoPage extends StatefulWidget {
  final Diacono diacono;

  DiaconoPage({required this.diacono});

  @override
  _DiaconoPageState createState() => _DiaconoPageState();
}

class _DiaconoPageState extends State<DiaconoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil do Diácono'),
      ),
      body: InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          padding: EdgeInsets.all(24.0),
          children: [
            Icon(
              Icons.account_circle,
              size: 128.0,
              color: Colors.grey,
            ),
            Text(
              widget.diacono.email,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(
              height: 24.0,
            ),
            TextFormField(
              initialValue: widget.diacono.nome,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                widget.diacono.nome = value;
              },
              decoration:
                  mTextFieldDecoration.copyWith(labelText: 'Nome completo'),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextFormField(
              initialValue:
                  cellMask.maskText(widget.diacono.telefone.toString()),
              inputFormatters: [cellMask],
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                widget.diacono.telefone = int.parse(cellMask.getUnmaskedText());
              },
              decoration: mTextFieldDecoration.copyWith(labelText: 'Whatsapp'),
            ),
            SizedBox(
              height: 24.0,
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: OutlinedButton.icon(
                    label: Text('Sair'),
                    icon: Icon(Icons.logout_rounded),
                    style: OutlinedButton.styleFrom(
                            primary: Colors.white, backgroundColor: Colors.red)
                        .merge(mOutlinedButtonStyle),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    },
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: SizedBox(
                      width: 12.0,
                    )),
                Expanded(
                  flex: 4,
                  child: OutlinedButton.icon(
                    label: Text('Atualizar dados'),
                    icon: Icon(Icons.save_rounded),
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
        return Center(child: CircularProgressIndicator());
      },
    );
    try {
      FirebaseFirestore.instance
          .collection('diaconos')
          .doc(widget.diacono.uid)
          .set(widget.diacono.toJson())
          .then((value) => Navigator.pop(context))
          .catchError((error) => print("Falha ao adicinar diacono: $error"));
    } catch (e) {
      print(e);
    }
    Navigator.pop(context);
  }
}
