import 'package:acao_ipbfoz/models/familia.dart';
import 'package:acao_ipbfoz/utils/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '/app_data.dart';
import '/main.dart';
import '/models/entrega.dart';
import '/models/entrega_itens.dart';
import '/utils/mensagens.dart';

class FamiliaEntregas extends StatefulWidget {
  final DocumentReference<Familia> refFamilia;
  const FamiliaEntregas({Key? key, required this.refFamilia}) : super(key: key);

  @override
  _FamiliaEntregasState createState() => _FamiliaEntregasState();
}

class _FamiliaEntregasState extends State<FamiliaEntregas> {
  /* VARIAVEIS */
  final _scrollController = ScrollController();
  late bool _cadastroNovo;

  /* WIDGETS */

  /// Botão adicionar entrega
  Widget get _btnAddEntrega {
    return OutlinedButton.icon(
      label: const Text('Nova entrega'),
      icon: const Icon(Icons.person_add),
      onPressed: !_cadastroNovo
          ? () {
              DocumentReference<Entrega> ref = widget.refFamilia
                  .collection('entregas')
                  .withConverter<Entrega>(
                    fromFirestore: (snapshots, _) =>
                        Entrega.fromJson(snapshots.data()!),
                    toFirestore: (documento, _) => documento.toJson(),
                  )
                  .doc();
              Entrega nova = Entrega(
                data: Timestamp.now(),
                diacono: auth.currentUser!.uid,
                itens: List<ItensEntrega>.empty(growable: true),
                entregue: false,
              );
              _dialogEntrega(ref, nova, true);
            }
          : null,
    );
  }

  /// Entregas
  Widget get _listaEntregas {
    return StreamBuilder<QuerySnapshot<Entrega>>(
      stream: widget.refFamilia
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
          return const Center(
            heightFactor: 5,
            child: Text('Nenhuma entrega realizada ainda.'),
          );
        }
        final data = snapshots.data;
        return Center(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.all(0),
              itemCount: data!.size,
              itemBuilder: (context, index) {
                Entrega iEntrega = data.docs[index].data();
                int totalItens = 0;
                for (var element in iEntrega.itens) {
                  totalItens += element.quantidade;
                }
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  title: Text(
                    totalItens.toString() + ' itens',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  subtitle: Text(
                      'Responsável: ${AppData.diaconos[iEntrega.diacono]?.nome ?? "[verificar]"}'),
                  trailing: iEntrega.entregue
                      ? IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.check_circle_rounded,
                            color: Colors.primaries.first,
                          ))
                      : const IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.grey,
                          )),
                  onTap: () {
                    _dialogEntrega(data.docs[index].reference, iEntrega, false);
                  },
                );
              }),
        );
      },
    );
  }

  /* METODOS */

  /// Adicionar nova entrega
  void _dialogEntrega(
      DocumentReference<Entrega> ref, Entrega entrega, bool isNew) {
    ItensEntrega novoItem =
        ItensEntrega(quantidade: 1, descricao: '', validade: Timestamp.now());

    _addItem() {
      entrega.itens.add(novoItem);
      novoItem =
          ItensEntrega(quantidade: 1, descricao: '', validade: Timestamp.now());
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 32.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
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
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    Expanded(
                      flex: 1,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(0),
                          itemCount: entrega.itens.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              horizontalTitleGap: 2,
                              visualDensity: VisualDensity.compact,
                              leading: Text(
                                  entrega.itens[index].quantidade.toString()),
                              title: Text(entrega.itens[index].descricao),
                              trailing: IconButton(
                                icon: const Icon(
                                    Icons.remove_circle_outline_rounded),
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
                          icon: const Icon(Icons.remove_circle_rounded),
                        ),
                        Text(
                          novoItem.quantidade.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                        IconButton(
                          onPressed: () {
                            setState.call(() => novoItem.quantidade += 1);
                          },
                          icon: const Icon(Icons.add_circle_rounded),
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
                          icon: const Icon(Icons.send_rounded),
                          onPressed: () {
                            setState.call(() => _addItem());
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      children: [
                        isNew
                            ? const Expanded(
                                flex: 1, child: SizedBox(width: 24.0))
                            : Expanded(
                                flex: 1,
                                child: OutlinedButton.icon(
                                  label: const Text('Excluir'),
                                  icon: const Icon(Icons.archive_rounded),
                                  style: OutlinedButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    Mensagem.decisao(
                                      context: context,
                                      titulo: 'Excluir',
                                      mensagem: 'Deseja excluir esse item?',
                                      onPressed: (value) {
                                        if (value == true) {
                                          Modular.to.pop(); // Fecha o dialogo
                                          setState(() {
                                            ref.delete();
                                          });
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                        const Expanded(flex: 0, child: SizedBox(width: 24.0)),
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            label: const Text('Salvar'),
                            icon: const Icon(Icons.save_rounded),
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

  /* METODOS DO SISTEMA */
  @override
  void initState() {
    _cadastroNovo = true;
    widget.refFamilia.get().then((value) {
      setState(() {
        _cadastroNovo = !value.exists;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      key: const PageStorageKey('entregas'),
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 24,
            horizontal: Util.paddingListH(context),
          ),
          child: Column(
            children: [
              _btnAddEntrega,
              const SizedBox(height: 8.0),
              _listaEntregas,
            ],
          ),
        ),
      ),
    );
  }
}
