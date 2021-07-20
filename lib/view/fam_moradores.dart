import 'package:acao_ipbfoz/models/morador.dart';
import 'package:acao_ipbfoz/ui/styles.dart';
import 'package:acao_ipbfoz/view/familia_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FamiliaMoradores extends StatefulWidget {
  FamiliaMoradores();

  @override
  _FamiliaMoradoresState createState() => _FamiliaMoradoresState();
}

class _FamiliaMoradoresState extends State<FamiliaMoradores> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            OutlinedButton.icon(
              label: Text('Adicionar morador'),
              icon: Icon(Icons.person_add),
              style: mOutlinedButtonStyle,
              onPressed: () {
                _dialogAddMorador();
              },
            ),
            ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                //itemCount: 1,
                itemCount: familia.moradores.length,
                itemBuilder: (context, index) {
                  String idade =
                      _calcularIdade(familia.moradores[index].nascimento);
                  String profissao = familia.moradores[index].profissao;
                  return ListTile(
                    title: Text(familia.moradores[index].nome),
                    subtitle: Text('$idade • $profissao'),
                    //title: Text(familia.moradores[index].nome),
                  );
                }),
          ],
        ),
      ),
    );
  }

  void _dialogAddMorador() {
    Morador morador = new Morador(
        nome: '',
        nascimento: Timestamp.now(),
        escolaridade: 0,
        profissao: '',
        especial: false);
    showModalBottomSheet(
      //isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            //padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 56.0),
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: MediaQuery.of(context).padding.top),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              children: [
                Text(
                  'Novo morador',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                SizedBox(
                  height: 16.0,
                ),
                // Nome
                TextFormField(
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration:
                      mTextFieldDecoration.copyWith(labelText: 'Nome Completo'),
                  onChanged: (value) {
                    morador.nome = value;
                  },
                ),
                SizedBox(
                  height: 8.0,
                ),
                // Nascimento
                InputDecorator(
                  decoration: mTextFieldDecoration.copyWith(
                      labelText: 'Data de nascimento'),
                  child: InputDatePickerFormField(
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    fieldHintText: null,
                    fieldLabelText: '',
                    errorFormatText: 'Formato inválido',
                    errorInvalidText: 'Data inválida',
                    onDateSubmitted: (value) {
                      morador.nascimento = Timestamp.fromDate(value);
                    },
                  ),
                ),

                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                  keyboardType: TextInputType.datetime,
                  textInputAction: TextInputAction.next,
                  decoration: mTextFieldDecoration.copyWith(
                      labelText: 'Data de nascimento'),
                  onChanged: (value) {},
                ),
                SizedBox(
                  height: 8.0,
                ),
                // Escolaridade
                TextFormField(
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration:
                      mTextFieldDecoration.copyWith(labelText: 'Escolaridade'),
                  onChanged: (value) {
                    morador.escolaridade = int.parse(value);
                  },
                ),
                SizedBox(
                  height: 8.0,
                ),
                // Profissao
                TextFormField(
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration:
                      mTextFieldDecoration.copyWith(labelText: 'Profissão'),
                  onChanged: (value) {
                    morador.profissao = value;
                  },
                ),
                SizedBox(
                  height: 8.0,
                ),
                // E Especial
                ListTile(
                    title: Text("Possui necessidades especiais"),
                    leading: Checkbox(
                      value: morador.especial,
                      onChanged: (value) {
                        setState(() {
                          morador.especial = value!;
                        });
                      },
                    )),
                SizedBox(
                  height: 8.0,
                ),
                OutlinedButton.icon(
                  label: Text('Salvar'),
                  icon: Icon(Icons.save_rounded),
                  style: mOutlinedButtonStyle,
                  onPressed: () {
                    Navigator.pop(context, true);
                    setState(() {
                      familia.moradores.add(morador);
                    });
                  },
                ),
              ],
            ),
          );
        });
      },
    ).then((value) {
      if (value) setState(() {});
    });
  }

  String _calcularIdade(Timestamp nascimento) {
    int idade = DateTime.now().difference(nascimento.toDate()).inDays;
    if (idade < 31)
      return 'Recém-nascido';
    else if (idade < 366) {
      idade = idade ~/ 30;
      return '$idade meses';
    } else if (idade < (365 * 2)) {
      idade = idade ~/ 365;
      return '$idade ano';
    } else {
      idade = idade ~/ 365;
      return '$idade anos';
    }
  }
}
