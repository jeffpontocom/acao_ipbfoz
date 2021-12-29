import 'dart:developer' as dev;

import 'package:acao_ipbfoz/models/familia.dart';
import 'package:acao_ipbfoz/models/resumo.dart';
import 'package:acao_ipbfoz/utils/customs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:ionicons/ionicons.dart';
import 'package:search_cep/search_cep.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /* WIDGETS */

  // Situação cadastral
  Widget get _situacao {
    return SliverAppBar(
      backgroundColor:
          widget.familia.cadAtivo ? Colors.grey.shade300 : Colors.red,
      floating: true,
      pinned: editMode,
      leading: null,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: ListTile(
        leading: const Icon(Icons.family_restroom),
        horizontalTitleGap: 0,
        title: Text(
          widget.familia.cadAtivo ? 'Situação: ATIVO' : 'Situação: INATIVO',
        ),
        subtitle: Text(
          'Cadastrada em ${Util.fmtDataCurta.format(widget.familia.cadData.toDate())}.',
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
        // Familiar responsável (combo box)
        DropdownButtonFormField<int>(
          value: widget.familia.moradores.indexWhere(
              (element) => element.nome == widget.familia.cadNomeFamilia),
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
                    widget.familia.cadNomeFamilia =
                        widget.familia.moradores[value ?? 0].nome;
                  });
                }
              : null,
        ),
        const SizedBox(height: 16),
        // Whatsapp
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                enabled: editMode,
                initialValue: widget.familia.famTelefone1 == 0
                    ? ''
                    : Inputs.mascaraFone.getMaskedString(
                        widget.familia.famTelefone1.toString()),
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
              child: SizedBox(width: 16),
            ),
            // Botão de ação
            Expanded(
              flex: 1,
              child: TextButton.icon(
                onPressed: (widget.familia.famTelefone1 == null ||
                        widget.familia.famTelefone1! < 1000000000)
                    ? null
                    : _iniciarWhatsApp,
                icon: const Icon(Ionicons.logo_whatsapp),
                label: const Text('WHATS'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Telefone Secundário
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                enabled: editMode,
                initialValue: widget.familia.famTelefone2 == 0
                    ? ''
                    : Inputs.mascaraFone.getMaskedString(
                        widget.familia.famTelefone2.toString()),
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
            const Expanded(
              flex: 0,
              child: SizedBox(width: 16.0),
            ),
            // Botão de ação
            Expanded(
              flex: 1,
              child: TextButton.icon(
                onPressed: (widget.familia.famTelefone2 == null ||
                            widget.familia.famTelefone2! < 1000000000) &&
                        (widget.familia.famTelefone1 == null ||
                            widget.familia.famTelefone1! < 1000000000)
                    ? null
                    : _iniciarTelefone,
                icon: const Icon(Icons.phone),
                label: const Text('LIGAR'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Endereço
  final TextEditingController _ctrLogradouro = TextEditingController();
  final TextEditingController _ctrBairro = TextEditingController();
  Widget get _endereco {
    _ctrLogradouro.text = widget.familia.endLogradouro ?? '';
    _ctrBairro.text = widget.familia.endBairro ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subtitulo('ENDEREÇO'),
        Row(
          children: [
            // CEP
            Expanded(
              flex: 2,
              child: TextFormField(
                enabled: editMode,
                initialValue: widget.familia.endCEP == 0
                    ? ''
                    : Inputs.mascaraCEP
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
                onFieldSubmitted: (value) {
                  _completarPorCep();
                },
              ),
            ),
            const Expanded(
              flex: 0,
              child: SizedBox(width: 16.0),
            ),
            // Botão de Ação (Rota do Google)
            Expanded(
              flex: 1,
              child: TextButton.icon(
                onPressed: (widget.familia.endLogradouro == null ||
                        widget.familia.endLogradouro!.isEmpty)
                    ? null
                    : _iniciarGoogleMaps,
                icon: const Icon(Icons.map),
                label: const Text('MAPA'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),

        // Logradouro
        TextFormField(
          enabled: editMode,
          controller: _ctrLogradouro,
          //initialValue: widget.familia.endLogradouro,
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
        Row(
          children: [
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
            const Expanded(
              flex: 0,
              child: SizedBox(width: 16.0),
            ),
            // Bairro
            Expanded(
              flex: 2,
              child: TextFormField(
                enabled: editMode,
                controller: _ctrBairro,
                //initialValue: widget.familia.endBairro,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.streetAddress,
                textInputAction: TextInputAction.next,
                selectionControls: materialTextSelectionControls,
                decoration:
                    Estilos.mInputDecoration.copyWith(labelText: 'Bairro'),
                onChanged: (value) {
                  widget.familia.endBairro = value;
                },
              ),
            ),
          ],
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
              flex: 2,
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
        // Participa da igreja
        StatefulBuilder(
          builder: (context, setState) {
            return CheckboxListTile(
              tristate: false,
              title: const Text("Participa da igreja"),
              visualDensity: VisualDensity.compact,
              subtitle: const Text(
                  "Ao menos um familiar é membro ou participa dos cultos"),
              secondary: const Icon(Icons.hail),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              tileColor: Colors.grey.shade200,
              selectedTileColor: Colors.teal.shade100,
              selected: widget.familia.cadParticipante ?? false,
              value: widget.familia.cadParticipante,
              onChanged: editMode
                  ? (value) {
                      setState(() {
                        widget.familia.cadParticipante = value ?? false;
                      });
                    }
                  : null,
            );
          },
        ),
        const SizedBox(height: 16.0),
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
    return editMode
        ? ElevatedButton.icon(
            label: Text(widget.familia.cadAtivo ? 'DESATIVAR' : 'REATIVAR'),
            icon: Icon(widget.familia.cadAtivo
                ? Icons.archive_rounded
                : Icons.open_in_browser),
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
            label: const Text('ELIMINAR'),
            icon: const Icon(Icons.delete_forever),
            style: ElevatedButton.styleFrom(primary: Colors.red),
            onPressed: () {
              _eliminarCadastro();
            },
          )
        : const SizedBox();
  }

  /* METODOS */

  /// Iniciar Google Maps
  void _iniciarGoogleMaps() {
    var query = (widget.familia.endLogradouro ?? "") +
        ', ' +
        (widget.familia.endNumero ?? "") +
        ', ' +
        'Foz do Iguaçu';
    MapsLauncher.launchQuery(query);
  }

  /// Iniciar Whatsapp
  void _iniciarWhatsApp() async {
    var url = 'https://wa.me/55${widget.familia.famTelefone1}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não é possível abrir o Whatsapp';
    }
  }

  /// Iniciar Telefone
  void _iniciarTelefone() async {
    int? telefone;
    if (widget.familia.famTelefone2 == null ||
        widget.familia.famTelefone2! < 1000000000) {
      telefone = widget.familia.famTelefone1;
    } else {
      telefone = widget.familia.famTelefone2;
    }
    var url = 'tel:${telefone.toString()}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não é possivel realizar ligações nesse aparelho';
    }
  }

  /// Completar dados pelo CEP
  void _completarPorCep() async {
    // Abre tela de progresso
    Mensagem.aguardar(context: context, mensagem: 'Consultando CEP...');
    final viaCepSearchCep = ViaCepSearchCep();
    final infoCep = await viaCepSearchCep.searchInfoByCep(
        cep: widget.familia.endCEP.toString());
    Navigator.pop(context); // Fecha tela de progresso
    infoCep.fold((l) {
      // não é possível executar alterações
      Mensagem.simples(
        context: context,
        titulo: 'Atenção',
        mensagem: l.errorMessage,
      );
    }, (r) {
      //deseja executar alterações
      Mensagem.decisao(
        context: context,
        titulo: 'Alterar dados',
        mensagem:
            'Deseja alterar os campos de Logradouro e Bairro a partir do CEP informado?',
        onPressed: (executar) {
          if (executar) {
            _ctrLogradouro.text = r.logradouro ?? '';
            _ctrBairro.text = r.bairro ?? '';
            widget.familia.endLogradouro = r.logradouro;
            widget.familia.endBairro = r.bairro;
            widget.familia.endCidade = r.localidade;
            widget.familia.endEstado = r.uf;
            setState(() {});
          }
        },
      );
    });
  }

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
      // Executa ação
      widget.reference.set(widget.familia).then((value) {
        Navigator.pop(context); // Fecha a tela de progresso
        editMode = false;
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
      onPressed: (value) async {
        if (value) {
          // Abre tela de progresso
          Mensagem.aguardar(context: context, mensagem: 'Alterando status...');
          int incremento;
          if (widget.familia.cadAtivo) {
            await widget.reference.update({'cadAtivo': false});
            incremento = -1;
          } else {
            await widget.reference.update({'cadAtivo': true});
            incremento = 1;
          }
          // Modifica Resumo
          FirebaseFirestore.instance
              .collection(Resumo.colecao)
              .doc('geral')
              .update(
                  {'resumoFamiliasAtivas': FieldValue.increment(incremento)});
          widget.familia.cadAtivo = !widget.familia.cadAtivo;
          editMode = false;
          Modular.to.pop(); // Fecha tela de progresso
          setState(() {
            _scrollController.jumpTo(0);
          });
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
    editMode = widget.editMode ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _collumnMaxWidth = 480;
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
                      constraints: BoxConstraints(maxWidth: _collumnMaxWidth),
                      child: _contatos,
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: _collumnMaxWidth),
                      child: _endereco,
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: _collumnMaxWidth),
                      child: _analiseSocial,
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: _collumnMaxWidth),
                      child: _controleCadastro,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
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
