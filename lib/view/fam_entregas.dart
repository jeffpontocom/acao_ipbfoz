import 'package:acao_ipbfoz/models/familia.dart';
import 'package:acao_ipbfoz/models/resumo.dart';
import 'package:acao_ipbfoz/utils/estilos.dart';
import 'package:acao_ipbfoz/utils/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/date_symbol_data_local.dart';

import '/app_data.dart';
import '/main.dart';
import '/models/entrega.dart';
import '/utils/mensagens.dart';

class FamiliaEntregas extends StatefulWidget {
  final Familia familia;
  final DocumentReference<Familia> refFamilia;
  const FamiliaEntregas(
      {Key? key, required this.familia, required this.refFamilia})
      : super(key: key);

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
      icon: const Icon(Icons.add_shopping_cart),
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
            child: Text('OCORREU UM ERRO:\n' + snapshots.error.toString()),
          );
        }
        if (!snapshots.hasData) {
          return const Center(
            heightFactor: 5,
            child: CircularProgressIndicator(),
          );
        }
        if (snapshots.data!.size == 0) {
          return Column(
            children: [
              const SizedBox(height: 64),
              Image.asset(
                'assets/images/transportation.png',
                width: 256,
              ),
              Text(
                'Nenhuma entrega realizada',
                style: Estilos.titulo,
              ),
            ],
          );
        }
        final data = snapshots.data;
        return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          controller: _scrollController,
          padding: const EdgeInsets.all(0),
          itemCount: data!.size,
          itemBuilder: (context, index) {
            Entrega iEntrega = data.docs[index].data();
            int totalItens = 0;
            for (var element in iEntrega.itens) {
              totalItens += element.quantidade;
            }
            return ListTile(
              leading: const Icon(Icons.delivery_dining),
              horizontalTitleGap: 0,
              title: Text(
                totalItens.toString() + ' itens',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              subtitle: Text((iEntrega.entregue
                      ? 'Entregue em ${Util.fmtDataLonga.format(iEntrega.data.toDate())}'
                      : 'Entrega pendente') +
                  '\n' +
                  'Responsável: ${AppData.diaconos[iEntrega.diacono]?.nome ?? "[verificar]"}'),
              trailing: iEntrega.entregue
                  ? IconButton(
                      tooltip: 'Desmarcar entrega',
                      icon: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.teal,
                      ),
                      onPressed: () {
                        Mensagem.decisao(
                            context: context,
                            titulo: 'Desmarcar entrega',
                            mensagem:
                                'Deseja desmarcar esse item como entregue?',
                            onPressed: (value) {
                              if (value) {
                                data.docs[index].reference
                                    .update({'entregue': false});
                              }
                            });
                      },
                    )
                  : IconButton(
                      tooltip: 'Registrar entrega',
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.grey,
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          helpText: 'Data de entrega',
                          context: context,
                          locale: const Locale('pt', 'BR'),
                          initialDate: iEntrega.data.toDate(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          data.docs[index].reference
                              .update({'data': Timestamp.fromDate(picked)});
                          data.docs[index].reference.update({'entregue': true});
                        }
                      },
                    ),
              onTap: () {
                _dialogEntrega(data.docs[index].reference, iEntrega, false);
              },
            );
          },
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

    TextEditingController _descricao =
        TextEditingController(text: novoItem.descricao);

    Widget _conteudo = StatefulBuilder(builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              entrega.entregue
                  ? 'Entregue em ${Util.fmtDataLonga.format(entrega.data.toDate())}'
                  : 'Entrega pendente',
              textAlign: TextAlign.center,
              style: TextStyle(backgroundColor: Colors.amber.shade300),
            ),
            const SizedBox(height: 16),
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
                      leading: Text(entrega.itens[index].quantidade.toString()),
                      title: Text(entrega.itens[index].descricao),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        onPressed: () {
                          setState.call(() => entrega.itens.removeAt(index));
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
                    controller: _descricao,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.send,
                    onChanged: (value) {
                      novoItem.descricao = value;
                    },
                    onFieldSubmitted: (value) {
                      _addItem();
                      _descricao.text = '';
                      setState.call(() {});
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: () {
                    _addItem();
                    _descricao.text = '';
                    setState.call(() {});
                  },
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isNew
                    ? const SizedBox(width: 150)
                    : OutlinedButton.icon(
                        label: const Text('EXCLUIR'),
                        icon: const Icon(Icons.archive_rounded),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          Mensagem.decisao(
                            context: context,
                            titulo: 'Excluir',
                            mensagem: 'Deseja excluir esse item?',
                            onPressed: (value) async {
                              if (value) {
                                Modular.to.pop(); // Fecha o dialogo
                                // Tela de progresso
                                Mensagem.aguardar(
                                    context: context, mensagem: 'Excluindo...');
                                // Ação
                                await ref.delete();
                                // Modifica Resumo
                                await _incrementarEntrega(-1);
                                // Fecha a tela de progresso
                                Modular.to.pop();
                              }
                            },
                          );
                        },
                      ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    label: const Text('SALVAR'),
                    icon: const Icon(Icons.save_rounded),
                    onPressed: () async {
                      Modular.to.pop(); // Fecha o dialogo
                      // Tela de progresso
                      Mensagem.aguardar(
                          context: context, mensagem: 'Registrando...');
                      // Ação
                      await ref.set(entrega);
                      // Modifica Resumo
                      isNew ? await _incrementarEntrega(1) : null;
                      // Fecha a tela de progresso
                      Modular.to.pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });

    // Dialog
    Mensagem.bottomDialog(
      context: context,
      titulo: 'Cadastro de entrega',
      conteudo: _conteudo,
      icon: Icons.delivery_dining,
      onPressed: () => setState(() {}),
    );
  }

  Future<void> _incrementarEntrega(int incremento) async {
    int ano = DateTime.now().year;
    int mes = DateTime.now().month;
    await FirebaseFirestore.instance
        .collection(Resumo.colecao)
        .doc('geral')
        .withConverter<Resumo>(
          fromFirestore: (snapshots, _) => Resumo.fromJson(snapshots.data()!),
          toFirestore: (documento, _) => documento.toJson(),
        )
        .get()
        .then((value) async {
      List<ResumoEntregas> lista = value.data()?.resumoEntregas ?? [];
      var index = lista
          .indexWhere((element) => element.ano == ano && element.mes == mes);
      if (index == -1) {
        lista.add(ResumoEntregas(ano: ano, mes: mes, total: incremento));
      } else {
        lista[index].total += incremento;
      }
      await value.reference.update({
        'resumoEntregas':
            List<dynamic>.from(lista.map((entregas) => entregas.toJson()))
      });
    });
  }

  /* METODOS DO SISTEMA */
  @override
  void initState() {
    initializeDateFormatting('pt_BR', null);
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
          padding: EdgeInsets.symmetric(horizontal: Util.paddingListH(context)),
          child: Column(
            children: [
              widget.familia.cadAtivo
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: _btnAddEntrega)
                  : const SizedBox(),
              _listaEntregas,
            ],
          ),
        ),
      ),
    );
  }
}
