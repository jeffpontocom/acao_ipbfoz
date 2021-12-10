import 'package:acao_ipbfoz/models/familia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/data/escolaridade.dart';
import '/models/morador.dart';
import '/utils/estilos.dart';
import '/utils/mensagens.dart';
import '/utils/util.dart';

class FamiliaMoradores extends StatefulWidget {
  final Familia familia;
  final DocumentReference<Familia> reference;
  const FamiliaMoradores(
      {Key? key, required this.familia, required this.reference})
      : super(key: key);

  @override
  _FamiliaMoradoresState createState() => _FamiliaMoradoresState();
}

class _FamiliaMoradoresState extends State<FamiliaMoradores> {
  /* VARIAVEIS */
  final _scrollController = ScrollController();

  /* WIDGETS */

  /// Botão adicionar morador
  Widget get _btnAddMorador {
    return OutlinedButton.icon(
      label: const Text('Adicionar morador'),
      icon: const Icon(Icons.person_add),
      onPressed: () {
        _dialogMorador(null, 9999);
      },
    );
  }

  /// Lista de Moradores
  Widget get _listaMoradores {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      controller: _scrollController,
      padding: const EdgeInsets.all(0),
      itemCount: widget.familia.moradores.length,
      itemBuilder: (context, index) {
        var mIdade = _calcularIdade(widget.familia.moradores[index].nascimento);
        String sIdade = _mostrarIdade(mIdade.keys.first, mIdade.values.first);
        String profissao = widget.familia.moradores[index].profissao;
        return ListTile(
          horizontalTitleGap: 2,
          visualDensity: VisualDensity.compact,
          leading: const Icon(Icons.person),
          title: Text(widget.familia.moradores[index].nome),
          subtitle: Text('$sIdade • $profissao'),
          onTap: () {
            _dialogMorador(widget.familia.moradores[index], index);
          },
        );
      },
    );
  }

  /* METODOS */

  /// Cria novo registro de morador
  void _dialogMorador(Morador? valor, int pos) {
    Morador morador = Morador(
        nome: '',
        nascimento: Timestamp.fromDate(DateTime(1800)),
        escolaridade: 0,
        profissao: '',
        especial: false);
    if (valor != null) {
      morador = Morador.fromJson(valor.toJson());
    }
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      isDismissible: false,
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: MediaQuery.of(context).viewInsets.top),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                children: [
                  Row(
                    children: [
                      const CloseButton(),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Cadastro do morador',
                          textAlign: TextAlign.center,
                          style: Estilos.titulo,
                        ),
                      ),
                      const IconButton(
                        onPressed: null,
                        icon: Icon(Icons.person),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  // Nome
                  TextFormField(
                    initialValue: morador.nome,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    decoration: Estilos.mInputDecoration
                        .copyWith(labelText: 'Nome completo'),
                    onChanged: (value) {
                      morador.nome = value;
                    },
                  ),
                  const SizedBox(height: 8.0),

                  Row(
                    children: [
                      // Nascimento
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          initialValue: morador.nascimento.toDate().year == 1800
                              ? ''
                              : Inputs.mascaraData
                                  .format(morador.nascimento.toDate()),
                          keyboardType: TextInputType.datetime,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [Inputs.textoData],
                          decoration: Estilos.mInputDecoration.copyWith(
                              labelText: 'Nascimento', hintText: 'xx/xx/xxxx'),
                          onChanged: (value) {
                            if (value.isEmpty || value.contains('x')) {
                              morador.nascimento =
                                  Timestamp.fromDate(DateTime(1800));
                            }
                            if (value.length >= 10) {
                              DateTime date = Inputs.mascaraData.parse(value);
                              morador.nascimento = Timestamp.fromDate(date);
                            }
                          },
                        ),
                      ),
                      const Expanded(
                        flex: 0,
                        child: SizedBox(width: 8.0),
                      ),
                      // Escolaridade
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<int>(
                          value: morador.escolaridade,
                          decoration: Estilos.mInputDecoration.copyWith(
                              labelText: 'Escolaridade', isDense: true),
                          focusNode: FocusNode(
                            skipTraversal: true,
                          ),
                          items: Escolaridade.values
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value.index,
                                  child: Text(getEscolaridadeString(value)),
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
                  const SizedBox(height: 8.0),
                  // Profissao
                  TextFormField(
                    initialValue: morador.profissao,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    decoration: Estilos.mInputDecoration
                        .copyWith(labelText: 'Profissão'),
                    onChanged: (value) {
                      morador.profissao = value;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  // E Especial
                  ListTile(
                      title: const Text("Possui necessidades especiais"),
                      leading: Checkbox(
                        value: morador.especial,
                        onChanged: (value) {
                          setState(() {
                            morador.especial = value!;
                          });
                        },
                      )),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      pos == 9999
                          ? const SizedBox()
                          : OutlinedButton.icon(
                              label: const Text('EXCLUIR'),
                              icon: const Icon(Icons.archive_rounded),
                              style: OutlinedButton.styleFrom(
                                primary: Colors.white,
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                Mensagem.decisao(
                                  context: context,
                                  titulo: 'Excluir',
                                  mensagem:
                                      'Deseja excluir o registro desse morador?',
                                  onPressed: (value) {
                                    if (value) {
                                      widget.familia.moradores.removeAt(pos);
                                      widget.reference.update({
                                        'moradores': List<dynamic>.from(widget
                                            .familia.moradores
                                            .map((morador) => morador.toJson()))
                                      }).then(
                                        // Fecha o dialogo
                                        (value) => Navigator.pop(context),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                      OutlinedButton.icon(
                        label: const Text('SALVAR'),
                        icon: const Icon(Icons.save_rounded),
                        onPressed: () {
                          Navigator.pop(context, true);
                          if (pos == 9999) {
                            widget.familia.moradores.add(morador);
                          } else {
                            widget.familia.moradores[pos] = morador;
                          }
                          widget.reference.update({
                            'moradores': List<dynamic>.from(widget
                                .familia.moradores
                                .map((morador) => morador.toJson()))
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((value) {
      setState(() {});
    });
  }

  /// Calcula a idade do morador
  Map<bool, int> _calcularIdade(Timestamp nascimento) {
    DateTime dataAtual = DateTime.now();
    DateTime dataNasc = nascimento.toDate();

    //Subtai para saber quantos anos se passaram após nascimento
    int idade = dataAtual.year - dataNasc.year;

    //data de nascimento não pode ser maior que data atual
    if (dataAtual.isBefore(dataNasc) || dataNasc.year == 1800) {
      return {false: -1};
    }
    //Verifica se está fazendo aniversário hoje
    else if (dataAtual.month == dataNasc.month &&
        dataAtual.day == dataNasc.day) {
      return {true: idade};
    }
    //Verifica se vai fazer aniversário este ano
    else if (dataAtual.month < dataNasc.month ||
        (dataAtual.month == dataNasc.month && dataAtual.day < dataNasc.day)) {
      idade = idade - 1;
      return {false: idade};
    }
    //Se nenhuma das opções anteriores, então já fez aniversário este ano
    else {
      return {false: idade};
    }
  }

  /// Mostrar a idade (em anos)
  String _mostrarIdade(bool isBirthday, int idade) {
    //data de nascimento não pode ser maior que data atual
    if (idade == -1) {
      return "Sem idade definida!";
    }
    //Verifica se está fazendo aniversário hoje
    else if (isBirthday) {
      return "$idade ano${Util.isPlural(idade)} - Aniversariante!";
    }
    //Se nenhuma das opções anteriores, então já fez aniversário este ano
    else {
      return "$idade ano${Util.isPlural(idade)}";
    }
  }

  /* METODOS DO SISTEMA */
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      key: const PageStorageKey('moradores'),
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Util.paddingListH(context), vertical: 24),
          child: Column(
            children: [
              _btnAddMorador,
              const SizedBox(height: 8.0),
              _listaMoradores,
            ],
          ),
        ),
      ),
    );
  }
}
