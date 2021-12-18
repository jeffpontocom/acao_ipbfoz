import 'package:acao_ipbfoz/models/familia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

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
        var mIdade = _calcularIdade(
            widget.familia.moradores[index].nascimento ?? Timestamp.now());
        String sIdade = _mostrarIdade(mIdade.keys.first, mIdade.values.first);
        String profissao = widget.familia.moradores[index].profissao ?? '';
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
    Morador morador = Morador(nome: '', especial: false);
    if (valor != null) {
      morador = Morador.fromJson(valor.toJson());
    }
    bool isPrincipal = morador.nome == widget.familia.cadNomeFamilia;
    // Controladores
    TextEditingController _dataNasc = TextEditingController(
        text: morador.nascimento == null
            ? ''
            : Util.fmtDataCurta
                .format(morador.nascimento?.toDate() ?? DateTime.now()));
    // Widget conteudo
    Widget _conteudo = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nome
          TextFormField(
            initialValue: morador.nome,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            decoration:
                Estilos.mInputDecoration.copyWith(labelText: 'Nome completo'),
            onChanged: (value) {
              morador.nome = value;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Nascimento
              Expanded(
                flex: 3,
                child: TextFormField(
                  readOnly: true,
                  controller: _dataNasc,
                  decoration: Estilos.mInputDecoration.copyWith(
                    labelText: 'Nascimento',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          helpText: 'Data de Nascimento',
                          context: context,
                          locale: const Locale('pt', 'BR'),
                          initialDate:
                              morador.nascimento?.toDate() ?? DateTime.now(),
                          firstDate: DateTime(1800),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          morador.nascimento = Timestamp.fromDate(picked);
                          _dataNasc.text = Inputs.mascaraData
                              .format(morador.nascimento!.toDate());
                        }
                      },
                    ),
                  ),
                ),
              ),
              const Expanded(
                flex: 0,
                child: SizedBox(width: 8),
              ),
              // Escolaridade
              Expanded(
                flex: 4,
                child: DropdownButtonFormField<int>(
                  value: morador.escolaridade,
                  decoration: Estilos.mInputDecoration
                      .copyWith(labelText: 'Escolaridade'),
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
          const SizedBox(height: 16),
          // Profissao
          TextFormField(
            initialValue: morador.profissao,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            decoration:
                Estilos.mInputDecoration.copyWith(labelText: 'Profissão'),
            onChanged: (value) {
              morador.profissao = value;
            },
          ),
          const SizedBox(height: 16),
          // E Especial
          StatefulBuilder(
            builder: (context, setState) {
              return CheckboxListTile(
                tristate: false,
                title: const Text("PNE"),
                visualDensity: VisualDensity.compact,
                subtitle: const Text("Portador de Necessidades Especiais"),
                secondary: const Icon(Icons.accessible),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                tileColor: Colors.grey.shade200,
                selectedTileColor: Colors.amber,
                selected: morador.especial,
                value: morador.especial,
                onChanged: (value) {
                  setState(() {
                    morador.especial = value ?? false;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 32),
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
                        widget.familia.moradores.length <= 1
                            ? Mensagem.simples(
                                context: context,
                                titulo: 'Atenção',
                                mensagem:
                                    'Não é possível excluir!\nÉ necessário no mínimo 1 morador cadastrado.')
                            : Mensagem.decisao(
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
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  label: const Text('SALVAR'),
                  icon: const Icon(Icons.save_rounded),
                  onPressed: () async {
                    // Fecha dialogo
                    Navigator.pop(context, true);
                    // Abre tela de espera
                    Mensagem.aguardar(
                        context: context, mensagem: 'Salvando...');
                    if (pos == 9999) {
                      widget.familia.moradores.add(morador);
                    } else {
                      widget.familia.moradores[pos] = morador;
                    }
                    // Atualiza moradores
                    await widget.reference.update({
                      'moradores': List<dynamic>.from(widget.familia.moradores
                          .map((morador) => morador.toJson()))
                    });
                    // Atualiza se morador principal
                    if (isPrincipal) {
                      widget.familia.cadNomeFamilia = morador.nome;
                      await widget.reference
                          .update({'cadNomeFamilia': morador.nome});
                    }
                    Modular.to.pop(); // Fecha tela de espera
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Dialog
    var scroll = ScrollController();
    Mensagem.bottomDialog(
        context: context,
        titulo: 'Cadastro do morador',
        scrollController: scroll,
        conteudo: Scrollbar(
          isAlwaysShown: true,
          showTrackOnHover: true,
          controller: scroll,
          child: SingleChildScrollView(
            child: _conteudo,
            controller: scroll,
          ),
        ),
        icon: Icons.person,
        onPressed: () => setState(() {}));
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
      return "[Registrar idade]";
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
          padding: EdgeInsets.symmetric(horizontal: Util.paddingListH(context)),
          child: Column(
            children: [
              widget.familia.cadAtivo
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: _btnAddMorador)
                  : const SizedBox(),
              _listaMoradores,
            ],
          ),
        ),
      ),
    );
  }
}
