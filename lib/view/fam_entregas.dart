import 'package:acao_ipbfoz/data/diaconos.dart';
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
                      DocumentReference<Entrega> ref = reference
                          .collection('entregas')
                          .withConverter<Entrega>(
                            fromFirestore: (snapshots, _) =>
                                Entrega.fromJson(snapshots.data()!),
                            toFirestore: (documento, _) => documento.toJson(),
                          )
                          .doc();
                      Entrega nova = new Entrega(
                        data: Timestamp.now(),
                        diacono: auth.currentUser!.uid,
                        itens: new List<ItensEntrega>.empty(growable: true),
                        entregue: false,
                      );
                      _dialogAddEntrega(ref, nova, true);
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
                          Entrega iEntrega = data.docs[index].data();
                          int totalItens = 0;
                          iEntrega.itens.forEach((element) {
                            totalItens += element.quantidade;
                          });
                          return ListTile(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 8.0),
                            title: Text(
                              totalItens.toString() + ' itens',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                            subtitle: Text('Responsável: ' +
                                diaconos[iEntrega.diacono]!.nome),
                            trailing: iEntrega.entregue
                                ? IconButton(
                                    onPressed: null,
                                    icon: Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.primaries.first,
                                    ))
                                : IconButton(
                                    onPressed: null,
                                    icon: Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Colors.grey,
                                    )),
                            onTap: () {
                              _dialogAddEntrega(
                                  data.docs[index].reference, iEntrega, false);
                            },
                          );
                        }),
                  );
                }),
          ],
        ),
      ),
    );
  }

  void _dialogAddEntrega(
      DocumentReference<Entrega> ref, Entrega entrega, bool isNew) {
    ItensEntrega novoItem = new ItensEntrega(
        quantidade: 1, descricao: '', validade: Timestamp.now());

    _addItem() {
      entrega.itens.add(novoItem);
      novoItem = new ItensEntrega(
          quantidade: 1, descricao: '', validade: Timestamp.now());
    }

    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: MediaQuery.of(context).padding.top),
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Cadastro de entrega',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    Expanded(
                      flex: 1,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          padding: EdgeInsets.all(0),
                          itemCount: entrega.itens.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              horizontalTitleGap: 2,
                              visualDensity: VisualDensity.compact,
                              leading: Text(
                                  entrega.itens[index].quantidade.toString()),
                              title: Text(entrega.itens[index].descricao),
                              trailing: IconButton(
                                icon: Icon(Icons.remove_circle_outline_rounded),
                                onPressed: () {
                                  setState.call(
                                      () => entrega.itens.removeAt(index));
                                },
                              ),
                            );
                          }),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState.call(() => novoItem.quantidade -= 1);
                          },
                          icon: Icon(Icons.remove_circle_rounded),
                        ),
                        Text(
                          novoItem.quantidade.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                        IconButton(
                          onPressed: () {
                            setState.call(() => novoItem.quantidade += 1);
                          },
                          icon: Icon(Icons.add_circle_rounded),
                        ),
                        // Nome
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.send,
                            onChanged: (value) {
                              novoItem.descricao = value;
                            },
                            onFieldSubmitted: (value) {
                              setState.call(() => _addItem());
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send_rounded),
                          onPressed: () {
                            setState.call(() => _addItem());
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    Row(
                      children: [
                        isNew
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
                                          ref.delete();
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
                                ref.set(entrega);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
          );
        });
      },
    ).then((value) {
      setState(() {});
    });
  }
}
