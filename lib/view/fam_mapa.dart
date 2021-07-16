import '/models/familia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FamiliaMapa extends StatefulWidget {
  FamiliaMapa(this.familia);
  final DocumentReference<Familia> familia;

  @override
  _FamiliaMapaState createState() => _FamiliaMapaState();
}

class _FamiliaMapaState extends State<FamiliaMapa> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 4),
      child: Text('Mapa'),
    );
  }
}
