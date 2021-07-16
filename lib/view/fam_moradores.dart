import '/models/familia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FamiliaMoradores extends StatefulWidget {
  FamiliaMoradores(this.reference);
  final DocumentReference<Familia> reference;

  @override
  _FamiliaMoradoresState createState() => _FamiliaMoradoresState();
}

class _FamiliaMoradoresState extends State<FamiliaMoradores> {
  late Familia familia;

  void _loadFamilia() async {
    familia = Familia.novaFamilia();
    await widget.reference
        .get()
        .then((value) => {if (value.exists) familia = value.data()!});
  }

  @override
  Widget build(BuildContext context) {
    _loadFamilia();
    return ListView.builder(
        padding: EdgeInsets.all(24.0),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: 1,
        //itemCount: familia.moradores.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Nome completo do morador'),
            subtitle: Text('58 anos • Profissão'),
            //title: Text(familia.moradores[index].nome),
          );
        });
  }
}
