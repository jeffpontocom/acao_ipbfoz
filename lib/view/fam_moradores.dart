import 'package:acao_ipbfoz/data/escolaridade.dart';
import 'package:acao_ipbfoz/models/morador.dart';
import 'package:acao_ipbfoz/ui/styles.dart';
import 'package:acao_ipbfoz/view/familia_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                Morador novo = new Morador(
                    nome: '',
                    nascimento: Timestamp.fromDate(DateTime(1800)),
                    escolaridade: 0,
                    profissao: '',
                    especial: false);
                _dialogAddMorador(novo, 9999);
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
                    onTap: () {
                      _dialogAddMorador(familia.moradores[index], index);
                    },
                  );
                }),
          ],
        ),
      ),
    );
  }

  void _dialogAddMorador(Morador morador, int pos) {
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
                  'Cadastro de morador',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                SizedBox(
                  height: 16.0,
                ),
                // Nome
                TextFormField(
                  initialValue: morador.nome,
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

                Row(
                  children: [
                    // Nascimento
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: morador.nascimento.toDate().year == 1800
                            ? ''
                            : dateMask.maskText(DateFormat('dd/MM/yyyy')
                                .format(morador.nascimento.toDate())),
                        keyboardType: TextInputType.datetime,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [dateMask],
                        decoration: mTextFieldDecoration.copyWith(
                            labelText: 'Data de nascimento'),
                        onChanged: (value) {
                          if (value.length == 10) {
                            DateTime date =
                                DateFormat('dd/MM/yyyy').parse(value);
                            morador.nascimento = Timestamp.fromDate(date);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: SizedBox(
                        width: 8.0,
                      ),
                    ),
                    // Escolaridade
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        value: morador.escolaridade,
                        decoration: mTextFieldDecoration.copyWith(
                            labelText: 'Escolaridade', isDense: true),
                        items: Escolaridade.values
                            .map(
                              (value) => new DropdownMenuItem(
                                value: value.index,
                                child: new Text(getEscolaridadeString(value)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            morador.escolaridade = value!;
                          });
                        },
                      ),
                    ),
                  ],
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
                      if (pos == 9999)
                        familia.moradores.add(morador);
                      else
                        familia.moradores[pos] = morador;
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
    DateTime dataAtual = DateTime.now();
    DateTime dataNasc = nascimento.toDate();

    //Subtai para saber quantos anos se passaram após nascimento
    int idade = dataAtual.year - dataNasc.year;

    //data de nascimento não pode ser maior que data atual
    if (dataAtual.isBefore(dataNasc) || dataNasc.year == 1800) {
      return "Data de nascimento indefinida!";
    }
    //Verifica se menor e 2 anos
    else if (idade < 2) {
      idade = (dataAtual.month - dataNasc.month) + (idade * 12);
      if (idade == 0)
        return 'Recém-nascido';
      else
        return "$idade mes(es)";
    }
    //Verifica se está fazendo aniversário hoje
    else if (dataAtual.month == dataNasc.month &&
        dataAtual.day == dataNasc.day) {
      return "$idade ano(s) (Aniversário hoje!) ";
    }
    //Verifica se vai fazer aniversário este ano
    else if (dataAtual.month < dataNasc.month ||
        (dataAtual.month == dataNasc.month && dataAtual.day < dataNasc.day)) {
      idade = idade - 1;
      return "$idade ano(s)";
    }
    //Se nenhuma das opções anteriores, então já fez aniversário este ano
    else {
      return "$idade anos(s)";
    }
  }
}
