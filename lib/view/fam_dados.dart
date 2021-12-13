import 'dart:developer' as dev;

import 'package:acao_ipbfoz/models/familia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '/app_data.dart';
import '/data/beneficios_gov.dart';
import '/utils/estilos.dart';
import '/utils/util.dart';
import '/utils/mensagens.dart';

class FamiliaDados extends StatefulWidget {
  final Familia familia;
  final DocumentReference<Familia> reference;
  final bool? editMode;
  const FamiliaDados(
      {Key? key, required this.familia, required this.reference, this.editMode})
      : super(key: key);

  @override
  _FamiliaDadosState createState() => _FamiliaDadosState();
}

class _FamiliaDadosState extends State<FamiliaDados> {
  /* VARIAVEIS */
  final _scrollController = ScrollController();
  late bool editMode;
  late bool cadastroNovo;

  /* WIDGETS */

  // Situação cadastral
  Widget get _situacao {
    return SliverAppBar(
      backgroundColor:
          widget.familia.cadAtivo ? Colors.grey.shade300 : Colors.red,
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
              : 'EM CRIAÇÃO',
        ),
        subtitle: Text(
          !cadastroNovo
              ? 'Cadastrada em ${Util.fmtDataCurta.format(widget.familia.cadData.toDate())}.'
              : 'Adicione um morador para salvar',
        ),
        trailing: TextButton.icon(
          label: Text(editMode ? 'SALVAR' : 'EDITAR'),
          icon: Icon(editMode ? Icons.save_rounded : Icons.mode_edit_rounded),
          style: TextButton.styleFrom(primary: Colors.black),
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Contato
  Widget get _contatos {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subtitulo('CONTATO'),
        // Familiar Responsavel
        Visibility(
          visible: widget.familia.moradores.isNotEmpty,
          child: Column(
            children: [
              // Familiar responsável (combo box)
              DropdownButtonFormField<int>(
                value: widget.familia.famResponsavel,
                iconDisabledColor: Colors.transparent,
                decoration: Estilos.mInputDecoration.copyWith(
                  labelText: 'Familiar responsável',
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
              const SizedBox(height: 16.0),
            ],
          ),
        ),
        // Telefones
        Row(
          children: [
            // Whatsapp
            Expanded(
              flex: 1,
              child: TextFormField(
                enabled: editMode,
                initialValue: widget.familia.famTelefone1 == 0
                    ? ''
                    : Inputs.mascaraFone.getMaskedString(
                        widget.familia.famTelefone1.toString()),
                inputFormatters: [Inputs.textoFone],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: Estilos.mInputDecoration.copyWith(
                  labelText: 'Whatsapp',
                  prefixIcon: const IconButton(
                    onPressed: null,
                    icon: Icon(Icons.perm_phone_msg),
                  ),
                ),
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
                width: 16.0,
              ),
            ),
            // Telefone
            Expanded(
              flex: 1,
              child: TextFormField(
                enabled: editMode,
                initialValue: widget.familia.famTelefone2 == 0
                    ? ''
                    : Inputs.mascaraFone.getMaskedString(
                        widget.familia.famTelefone2.toString()),
                inputFormatters: [Inputs.textoFone],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: Estilos.mInputDecoration.copyWith(
                  labelText: 'Telefone (outro)',
                  prefixIcon: const IconButton(
                    onPressed: null,
                    icon: Icon(Icons.settings_phone),
                  ),
                ),
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
        )
      ],
    );
  }

  // Endereço
  Widget get _endereco {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subtitulo('ENDEREÇO'),
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
                width: 16.0,
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
                decoration: Estilos.mInputDecoration.copyWith(
                  labelText: 'Número',
                  /* suffixIcon: const IconButton(
                    onPressed: null,
                    icon: Icon(Icons.map),
                  ), */
                ),
                onChanged: (value) {
                  widget.familia.endNumero = value;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
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
        const SizedBox(height: 16.0),
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
        const SizedBox(height: 16.0),
        // Referencia
        TextFormField(
          enabled: editMode,
          initialValue: widget.familia.endReferencia,
          textCapitalization: TextCapitalization.sentences,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subtitulo('ANALISE SOCIAL'),
        Row(
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
                    widget.familia.famRendaMedia =
                        Inputs.mascaraMoeda.parse(value);
                  }
                },
              ),
            ),
            const Expanded(
              flex: 0,
              child: SizedBox(width: 16.0),
            ),
            // Beneficio Governo (combo box)
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<int>(
                value: widget.familia.famBeneficioGov,
                iconDisabledColor: Colors.transparent,
                decoration: Estilos.mInputDecoration.copyWith(
                  labelText: 'Benefício do governo',
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
        )
      ],
    );
  }

  // Controle cadastral
  Widget get _controleCadastro {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subtitulo('CONTROLE IPBFOZ'),
        // Informacao Extra
        TextFormField(
          enabled: editMode,
          initialValue: widget.familia.extraInfo,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          //textInputAction: TextInputAction.next,
          minLines: 5,
          maxLines: 8,
          //textAlignVertical: TextAlignVertical.top,
          decoration: Estilos.mInputDecoration
              .copyWith(labelText: 'Informações extras'),
          onChanged: (value) {
            widget.familia.extraInfo = value;
          },
        ),
        const SizedBox(height: 16.0),
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
        const SizedBox(height: 16.0),
        // Diacono Responsavel (combo box)
        DropdownButtonFormField<String>(
          value: widget.familia.cadDiacono,
          iconDisabledColor: Colors.transparent,
          decoration: Estilos.mInputDecoration.copyWith(
            labelText: 'Diácono responsável',
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
    return !cadastroNovo && editMode
        ? ElevatedButton.icon(
            label: Text(widget.familia.cadAtivo
                ? 'Desativar cadastro'
                : 'Reativar cadastro'),
            icon: const Icon(Icons.archive_rounded),
            style: ElevatedButton.styleFrom(
                primary: widget.familia.cadAtivo ? Colors.red : Colors.teal),
            onPressed: () {
              _alterarSituacaoCadastro();
            },
          )
        : const SizedBox();
  }

  // Botão ativar/desativar cadastro
  Widget get _btnEliminar {
    return editMode && !widget.familia.cadAtivo
        ? ElevatedButton.icon(
            label: const Text('Eliminar cadastro'),
            icon: const Icon(Icons.delete_forever),
            style: ElevatedButton.styleFrom(primary: Colors.red),
            onPressed: () {
              _eliminarCadastro();
            },
          )
        : const SizedBox();
  }

  /* METODOS */

  /// Salva as alterações no banco de dados
  void _salvarDados() {
    if (widget.familia.moradores.isEmpty) {
      // Abre a mensagem de erro
      Mensagem.simples(
          context: context,
          titulo: 'Atenção',
          mensagem: 'Ao menos um morador deve ser cadastrado.');
      return;
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

  /// Altera a situação do cadastros (ativo/inativo)
  void _alterarSituacaoCadastro() {
    Mensagem.decisao(
      context: context,
      titulo: widget.familia.cadAtivo ? 'Desativar' : 'Reativar',
      mensagem: 'Está certo que deseja executar essa ação?',
      onPressed: (value) {
        WidgetsBinding.instance?.addPostFrameCallback(
          (_) => _scrollController.jumpTo(0),
        );

        if (value) {
          if (widget.familia.cadAtivo) {
            widget.reference.update({'cadAtivo': false});
          } else {
            widget.reference.update({'cadAtivo': true});
          }
          widget.familia.cadAtivo = !widget.familia.cadAtivo;
          editMode = false;
          setState(() {});
        }
      },
    );
  }

  /// Elimina o cadastro definitivamente
  void _eliminarCadastro() {
    Mensagem.decisao(
      context: context,
      titulo: 'Eliminar cadastro',
      mensagem:
          'Está certo que deseja executar essa ação?\n\nEssa ação não pode ser desfeita!',
      onPressed: (value) {
        if (value) {
          widget.reference.delete().then((value) => Modular.to.pop(true));
        }
      },
    );
  }

  /* METODOS DO SISTEMA */

  @override
  void initState() {
    cadastroNovo = widget.familia.moradores.isEmpty;
    editMode = widget.editMode ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _situacao,
        SliverToBoxAdapter(
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Scrollbar(
              key: const PageStorageKey('dados'),
              controller: _scrollController,
              isAlwaysShown: true,
              showTrackOnHover: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: _contatos,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: _endereco,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: _analiseSocial,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: _controleCadastro,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [_btnAtivar, _btnEliminar],
                      ),
                    ),
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
