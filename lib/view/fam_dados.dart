import 'dart:developer' as dev;

import 'package:acao_ipbfoz/models/familia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '/app_data.dart';
import '/data/beneficios_gov.dart';
import '/utils/estilos.dart';
import '/utils/util.dart';
import '/utils/mensagens.dart';

class FamiliaDados extends StatefulWidget {
  final Familia familia;
  final DocumentReference<Familia> reference;
  const FamiliaDados({Key? key, required this.familia, required this.reference})
      : super(key: key);

  @override
  _FamiliaDadosState createState() => _FamiliaDadosState();
}

class _FamiliaDadosState extends State<FamiliaDados> {
  /* VARIAVEIS */
  final _scrollController = ScrollController();
  bool editMode = false;
  bool cadastroNovo = true;

  /* WIDGETS */

  // Situação cadastral
  Widget get _situacao {
    return SliverAppBar(
      backgroundColor: Colors.grey.shade300,
      floating: true,
      leading: null,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: ListTile(
        leading: const Icon(Icons.family_restroom),
        horizontalTitleGap: 0,
        title: Text(
          !cadastroNovo
              ? widget.familia.cadAtivo
                  ? 'Situação: ATIVO'
                  : 'Situação: INATIVO'
              : 'Situação: EM CRIAÇÃO',
        ),
        subtitle: Text(
          'Registrada em ${Util.fmtDataCurta.format(widget.familia.cadData.toDate())}.',
        ),
        trailing: TextButton.icon(
          label: Text(editMode ? 'SALVAR' : 'EDITAR'),
          icon: Icon(editMode ? Icons.save_rounded : Icons.mode_edit_rounded),
          onPressed: () {
            if (editMode) {
              _salvarDados();
            } else {
              setState(() {
                editMode = true;
              });
            }
          },
        ),
      ),
    );
  }

  // Titulo do grupo
  Widget _subtitulo(String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Familiar Responsavel
  Widget get _famResponsavel {
    return Visibility(
      visible: widget.familia.moradores.isNotEmpty,
      child: Column(
        children: [
          // Familiar responsável (combo box)
          DropdownButtonFormField<int>(
            value: widget.familia.famResponsavel,
            iconDisabledColor: Colors.transparent,
            decoration: Estilos.mInputDecoration.copyWith(
              labelText: 'Familiar responsável',
              isDense: true,
              enabled: editMode,
            ),
            items: widget.familia.moradores
                .map(
                  (morador) => DropdownMenuItem(
                    value: widget.familia.moradores.indexOf(morador),
                    child: Text(morador.nome),
                  ),
                )
                .toList(),
            onChanged: editMode
                ? (value) {
                    setState(() {
                      widget.familia.famResponsavel = value!;
                    });
                  }
                : null,
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  // Telefones
  Widget get _contatos {
    return Row(
      children: [
        // Whatsapp
        Expanded(
          flex: 1,
          child: TextFormField(
            enabled: editMode,
            initialValue: widget.familia.famTelefone1 == 0
                ? ''
                : Inputs.mascaraFone
                    .getMaskedString(widget.familia.famTelefone1.toString()),
            inputFormatters: [Inputs.textoFone],
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration:
                Estilos.mInputDecoration.copyWith(labelText: 'Whatsapp'),
            onChanged: (value) {
              if (value.isEmpty) {
                widget.familia.famTelefone1 = 0;
              } else {
                widget.familia.famTelefone1 =
                    int.parse(Inputs.mascaraFone.clearMask(value));
              }
            },
          ),
        ),
        const Expanded(
          flex: 0,
          child: SizedBox(
            width: 8.0,
          ),
        ),
        // Telefone
        Expanded(
          flex: 1,
          child: TextFormField(
            enabled: editMode,
            initialValue: widget.familia.famTelefone2 == 0
                ? ''
                : Inputs.mascaraFone
                    .getMaskedString(widget.familia.famTelefone2.toString()),
            inputFormatters: [Inputs.textoFone],
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: Estilos.mInputDecoration
                .copyWith(labelText: 'Telefone (outro)'),
            onChanged: (value) {
              if (value.isEmpty) {
                widget.familia.famTelefone2 = 0;
              } else {
                widget.familia.famTelefone2 =
                    int.parse(Inputs.mascaraFone.clearMask(value));
              }
            },
          ),
        ),
      ],
    );
  }

  // Endereço
  Widget get _endereco {
    return Column(
      children: [
        Row(
          children: [
            // CEP
            Expanded(
              flex: 1,
              child: TextFormField(
                enabled: editMode,
                initialValue: Inputs.mascaraCEP
                    .getMaskedString(widget.familia.endCEP.toString()),
                inputFormatters: [Inputs.textoCEP],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: Estilos.mInputDecoration.copyWith(labelText: 'CEP'),
                onChanged: (value) {
                  if (value.isEmpty) {
                    widget.familia.endCEP = 0;
                  } else {
                    widget.familia.endCEP =
                        int.parse(Inputs.mascaraCEP.clearMask(value));
                  }
                },
              ),
            ),
            const Expanded(
              flex: 0,
              child: SizedBox(
                width: 8.0,
              ),
            ),
            // Número
            Expanded(
              flex: 1,
              child: TextFormField(
                enabled: editMode,
                initialValue: widget.familia.endNumero,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration:
                    Estilos.mInputDecoration.copyWith(labelText: 'Número'),
                onChanged: (value) {
                  widget.familia.endNumero = value;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        // Logradouro
        TextFormField(
          enabled: editMode,
          initialValue: widget.familia.endLogradouro,
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.streetAddress,
          textInputAction: TextInputAction.next,
          decoration:
              Estilos.mInputDecoration.copyWith(labelText: 'Logradouro'),
          onChanged: (value) {
            widget.familia.endLogradouro = value;
          },
        ),
        const SizedBox(height: 8.0),
        // Bairro
        TextFormField(
          enabled: editMode,
          initialValue: widget.familia.endBairro,
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.streetAddress,
          textInputAction: TextInputAction.next,
          selectionControls: materialTextSelectionControls,
          decoration: Estilos.mInputDecoration.copyWith(labelText: 'Bairro'),
          onChanged: (value) {
            widget.familia.endBairro = value;
          },
        ),
        const SizedBox(height: 8.0),
        // Referencia
        TextFormField(
          enabled: editMode,
          initialValue: widget.familia.endReferencia,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          minLines: 2,
          maxLines: 4,
          textAlignVertical: TextAlignVertical.top,
          textInputAction: TextInputAction.next,
          decoration:
              Estilos.mInputDecoration.copyWith(labelText: 'Referência'),
          onChanged: (value) {
            widget.familia.endReferencia = value;
          },
        ),
      ],
    );
  }

  // Analise Social
  Widget get _analiseSocial {
    return Row(
      children: [
        // Renda Media
        Expanded(
          flex: 1,
          child: TextFormField(
            enabled: editMode,
            initialValue:
                Inputs.mascaraMoeda.format(widget.familia.famRendaMedia),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter()
            ],
            textInputAction: TextInputAction.next,
            decoration: Estilos.mInputDecoration
                .copyWith(labelText: 'Renda Média', prefixText: 'R\$ '),
            onChanged: (value) {
              if (value.isEmpty) {
                widget.familia.famRendaMedia = 0;
              } else {
                widget.familia.famRendaMedia = Inputs.mascaraMoeda.parse(value);
              }
            },
          ),
        ),
        const Expanded(
          flex: 0,
          child: SizedBox(width: 8.0),
        ),
        // Beneficio Governo (combo box)
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<int>(
            value: widget.familia.famBeneficioGov,
            iconDisabledColor: Colors.transparent,
            decoration: Estilos.mInputDecoration.copyWith(
              labelText: 'Benefício do governo',
              isDense: true,
              enabled: editMode,
            ),
            focusNode: FocusNode(
              skipTraversal: true,
            ),
            items: Beneficios.values
                .map(
                  (value) => DropdownMenuItem(
                    value: value.index,
                    child: Text(getBeneficiosString(value)),
                  ),
                )
                .toList(),
            onChanged: editMode
                ? (value) {
                    setState(() {
                      widget.familia.famBeneficioGov = value!;
                    });
                  }
                : null,
          ),
        ),
      ],
    );
  }

  // Controle cadastral
  Widget get _controleCadastro {
    return Column(
      children: [
        // Informacao Extra
        TextFormField(
          enabled: editMode,
          initialValue: widget.familia.extraInfo,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.next,
          minLines: 5,
          maxLines: 8,
          textAlignVertical: TextAlignVertical.top,
          decoration: Estilos.mInputDecoration
              .copyWith(labelText: 'Informações extras'),
          onChanged: (value) {
            widget.familia.extraInfo = value;
          },
        ),
        const SizedBox(height: 8.0),
        // Solicitante
        TextFormField(
          enabled: editMode,
          initialValue: widget.familia.cadSolicitante,
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          decoration:
              Estilos.mInputDecoration.copyWith(labelText: 'Solicitante'),
          onChanged: (value) {
            widget.familia.cadSolicitante = value;
          },
        ),
        const SizedBox(height: 8.0),
        // Diacono Responsavel (combo box)
        DropdownButtonFormField<String>(
          value: widget.familia.cadDiacono,
          iconDisabledColor: Colors.transparent,
          decoration: Estilos.mInputDecoration.copyWith(
            labelText: 'Diácono responsável',
            isDense: true,
            enabled: editMode,
          ),
          focusNode: FocusNode(
            skipTraversal: true,
          ),
          items: AppData.diaconos.entries
              .map((mDiacono) => DropdownMenuItem(
                    value: mDiacono.key,
                    child: Text(mDiacono.value.nome ?? '[verificar]]'),
                  ))
              .toList(),
          onChanged: editMode
              ? (value) {
                  setState(() {
                    widget.familia.cadDiacono = value!.toString();
                  });
                }
              : null,
        ),
      ],
    );
  }

  // Botão ativar/desativar cadastro
  Widget get _btnAtivar {
    return Row(
      children: [
        !cadastroNovo && editMode
            ? Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  label: Text(widget.familia.cadAtivo
                      ? 'Desativar cadastro'
                      : 'Reativar cadastro'),
                  icon: const Icon(Icons.archive_rounded),
                  style: OutlinedButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    if (widget.familia.cadAtivo) {
                      widget.reference.update({'cadAtivo': false});
                    } else {
                      widget.reference.update({'cadAtivo': true});
                    }
                    widget.familia.cadAtivo = !widget.familia.cadAtivo;
                    setState(() {});
                  },
                ),
              )
            : const SizedBox(),
        const Expanded(flex: 1, child: SizedBox()),
      ],
    );
  }

  /* METODOS */

  /// Salva as alterações no banco de dados
  void _salvarDados() {
    if (widget.familia.moradores.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Atenção'),
          content: Text('Ao menos um morador deve ser cadastrado.'),
        ),
      ).then((value) {
        return;
      });
    } else {
      // Abre a tela de progresso
      Mensagem.aguardar(
          context: context, mensagem: 'Salvando dados cadastrais...');
      widget.reference.set(widget.familia).then((value) {
        Navigator.pop(context); // Fecha a tela de progresso
        editMode = false;
        cadastroNovo = false;
        setState(() {});
      }).catchError((error) {
        Navigator.pop(context); // Fecha a tela de progresso
        dev.log('Falha ao adicionar: $error', name: 'FamiliaPage');
      });
    }
  }

  /* METODOS DO SISTEMA */
  @override
  Widget build(BuildContext context) {
    cadastroNovo = widget.familia.moradores.isEmpty;
    return CustomScrollView(
      slivers: [
        _situacao,
        SliverToBoxAdapter(
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Scrollbar(
              key: const PageStorageKey('dados'),
              controller: _scrollController,
              isAlwaysShown: true,
              showTrackOnHover: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(
                    horizontal: Util.margemH(context), vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subtitulo('CONTATO'),
                    _famResponsavel,
                    _contatos,
                    _subtitulo('ENDEREÇO'),
                    _endereco,
                    _subtitulo('ANALISE SOCIAL'),
                    _analiseSocial,
                    _subtitulo('CONTROLE IPBFOZ'),
                    _controleCadastro,
                    const SizedBox(height: 36.0),
                    _btnAtivar,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
