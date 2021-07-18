import 'package:acao_ipbfoz/ui/styles.dart';
import 'package:flutter/material.dart';

class FamiliaMoradores extends StatefulWidget {
  FamiliaMoradores();

  @override
  _FamiliaMoradoresState createState() => _FamiliaMoradoresState();
}

class _FamiliaMoradoresState extends State<FamiliaMoradores> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            OutlinedButton.icon(
              label: Text('Adicionar morador'),
              icon: Icon(Icons.person_add),
              style: mOutlinedButtonStyle,
              onPressed: () {},
            ),
            ListView.builder(
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
                }),
          ],
        ));
  }
}
