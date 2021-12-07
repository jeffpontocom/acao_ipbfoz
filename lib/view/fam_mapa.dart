import 'package:flutter/material.dart';

class FamiliaMapa extends StatefulWidget {
  const FamiliaMapa({Key? key}) : super(key: key);

  @override
  _FamiliaMapaState createState() => _FamiliaMapaState();
}

class _FamiliaMapaState extends State<FamiliaMapa> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 4, top: 4),
      child: Center(
        child: Text('Em breve'),
      ),
    );
  }
}
