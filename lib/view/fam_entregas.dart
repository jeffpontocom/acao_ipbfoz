import 'package:acao_ipbfoz/main.dart';
import 'package:acao_ipbfoz/models/entrega_itens.dart';
import 'package:acao_ipbfoz/ui/dialogs.dart';
import 'package:acao_ipbfoz/ui/styles.dart';

import 'familia_page.dart';

import '../models/entrega.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FamiliaEntregas extends StatefulWidget {
  FamiliaEntregas();

  @override
  _FamiliaEntregasState createState() => _FamiliaEntregasState();
}

class _FamiliaEntregasState extends State<FamiliaEntregas> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            OutlinedButton.icon(
              label: Text('Nova entrega'),
              icon: Icon(Icons.person_add),
              style: mOutlinedButtonStyle,
              onPressed: onFirestore
                  ? () {
                      Entrega nova = new Entrega(
                        data: Timestamp.now(),
                        diacono: auth.currentUser!.uid,
                        itens: new List<ItensEntrega>.empty(growable: true),
                        entregue: false,
                      );
                      _dialogAddEntrega(nova, 9999);
                    }
                  : null,
            ),
            SizedBox(
              height: 8.0,
            ),
            StreamBuilder<QuerySnapshot<Entrega>>(
                stream: reference
                    .collection('entregas')
                    .orderBy('data', descending: false)
                    .withConverter<Entrega>(
                      fromFirestore: (snapshots, _) =>
                          Entrega.fromJson(snapshots.data()!),
                      toFirestore: (documento, _) => documento.toJson(),
                    )
                    .snapshots(),
                builder: (context, snapshots) {
                  if (snapshots.hasError) {
                    return Center(
                      heightFactor: 5,
                      child: Text(snapshots.error.toString()),
                    );
                  }
                  if (!snapshots.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshots.data!.size == 0) {
                    return Center(
                      heightFactor: 5,
                      child: Text('Nenhuma entrega realizada ainda.'),
                    );
                  }
                  final data = snapshots.data;
                  return Center(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        padding: EdgeInsets.all(0),
                        itemCount: data!.size,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(data.docs[index].id),
                          );
                        }),
                  );
                }),
          ],
        ),
      ),
    );
  }

  void _dialogAddEntrega(Entrega entrega, int pos) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: MediaQuery.of(context).padding.top),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              children: [
                Text(
                  'Cadastro de entrega',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                SizedBox(
                  height: 24.0,
                ),
                // Nome
                TextFormField(
                  initialValue: entrega.diacono,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                ),

                // Foi entregue
                ListTile(
                    title: Text("Foi entregue"),
                    leading: Checkbox(
                      value: entrega.entregue,
                      onChanged: (value) {
                        setState(() {
                          entrega.entregue = value!;
                        });
                      },
                    )),
                SizedBox(
                  height: 8.0,
                ),
                Row(
                  children: [
                    pos == 9999
                        ? Expanded(
                            flex: 1,
                            child: SizedBox(
                              width: 24.0,
                            ))
                        : Expanded(
                            flex: 1,
                            child: OutlinedButton.icon(
                              label: Text('Excluir'),
                              icon: Icon(Icons.archive_rounded),
                              style: mOutlinedButtonStyle
                                  .merge(OutlinedButton.styleFrom(
                                primary: Colors.white,
                                backgroundColor: Colors.red,
                              )),
                              onPressed: () {
                                showDialog(
                                        context: context,
                                        builder: (context) =>
                                            dialogConfirmaAcao(context))
                                    .then((value) {
                                  if (value != null && value == true) {
                                    Navigator.pop(context, true);
                                    setState(() {
                                      //entrega.delete();
                                    });
                                  }
                                });
                              },
                            ),
                          ),
                    Expanded(
                        flex: 0,
                        child: SizedBox(
                          width: 24.0,
                        )),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        label: Text('Salvar'),
                        icon: Icon(Icons.save_rounded),
                        style: mOutlinedButtonStyle,
                        onPressed: () {
                          Navigator.pop(context, true);
                          setState(() {
                            //if (pos == 9999)
                            //  familia.moradores.add(entrega);
                            //else
                            //  familia.moradores[pos] = entrega;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    ).then((value) {
      setState(() {});
    });
  }
}
