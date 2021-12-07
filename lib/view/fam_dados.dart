import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'familia_page.dart';
import '../app_data.dart';
import '../data/beneficios_gov.dart';
import '../ui/estilos.dart';
import '../utils/util.dart';

class FamiliaDados extends StatefulWidget {
  final bool editMode;
  const FamiliaDados({Key? key, required this.editMode}) : super(key: key);

  @override
  _FamiliaDadosState createState() => _FamiliaDadosState();
}

class _FamiliaDadosState extends State<FamiliaDados> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ListView(
        key: const PageStorageKey('dados'),
        padding: EdgeInsets.symmetric(
            horizontal: Util.margemH(context), vertical: 12),
        children: [
          // INFORMACAO GERAL
          Text(
            onFirestore
                ? familia.cadAtivo
                    ? 'Situação: ATIVO'
                    : 'Situação: INATIVO'
                : 'Situação: EM CRIAÇÃO',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
          Text(
            'Criado em ' +
                DateFormat.yMMMMd('pt_BR').format(familia.cadData.toDate()),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24.0),
          // DADOS EDITAVEIS
          const Text(
            'CONTATO',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Visibility(
            visible: familia.moradores.isNotEmpty,
            child: Column(
              children: [
                // Familiar responsável (combo box)
                DropdownButtonFormField<int>(
                  value: familia.famResponsavel,
                  iconDisabledColor: Colors.transparent,
                  decoration: mTextFieldDecoration.copyWith(
                    labelText: 'Familiar responsável',
                    isDense: true,
                    enabled: widget.editMode,
                  ),
                  items: familia.moradores
                      .map(
                        (morador) => DropdownMenuItem(
                          value: familia.moradores.indexOf(morador),
                          child: Text(morador.nome),
                        ),
                      )
                      .toList(),
                  onChanged: widget.editMode
                      ? (value) {
                          setState(() {
                            familia.famResponsavel = value!;
                          });
                        }
                      : null,
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),

          // Formas de Contato
          Row(
            children: [
              // Whatsapp
              Expanded(
                flex: 1,
                child: TextFormField(
                  enabled: widget.editMode,
                  initialValue: familia.famTelefone1 == 0
                      ? ''
                      : maskPhone
                          .getMaskedString(familia.famTelefone1.toString()),
                  inputFormatters: [inputPhone],
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration:
                      mTextFieldDecoration.copyWith(labelText: 'Whatsapp'),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      familia.famTelefone1 = 0;
                    } else {
                      familia.famTelefone1 =
                          int.parse(maskPhone.clearMask(value));
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
                  enabled: widget.editMode,
                  initialValue: familia.famTelefone2 == 0
                      ? ''
                      : maskPhone
                          .getMaskedString(familia.famTelefone2.toString()),
                  inputFormatters: [inputPhone],
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: mTextFieldDecoration.copyWith(
                      labelText: 'Telefone (outro)'),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      familia.famTelefone2 = 0;
                    } else {
                      familia.famTelefone2 =
                          int.parse(maskPhone.clearMask(value));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          const Text(
            'ENDEREÇO',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              // CEP
              Expanded(
                flex: 1,
                child: TextFormField(
                  enabled: widget.editMode,
                  initialValue:
                      maskCEP.getMaskedString(familia.endCEP.toString()),
                  inputFormatters: [inputCEP],
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: mTextFieldDecoration.copyWith(labelText: 'CEP'),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      familia.endCEP = 0;
                    } else {
                      familia.endCEP = int.parse(maskCEP.clearMask(value));
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
                  enabled: widget.editMode,
                  initialValue: familia.endNumero,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration:
                      mTextFieldDecoration.copyWith(labelText: 'Número'),
                  onChanged: (value) {
                    familia.endNumero = value;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          // Logradouro
          TextFormField(
            enabled: widget.editMode,
            initialValue: familia.endLogradouro,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.next,
            decoration: mTextFieldDecoration.copyWith(labelText: 'Logradouro'),
            onChanged: (value) {
              familia.endLogradouro = value;
            },
          ),
          const SizedBox(height: 8.0),
          // Bairro
          TextFormField(
            enabled: widget.editMode,
            initialValue: familia.endBairro,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.next,
            selectionControls: materialTextSelectionControls,
            decoration: Estilos.mInputDecoration.copyWith(labelText: 'Bairro'),
            onChanged: (value) {
              familia.endBairro = value;
            },
          ),
          const SizedBox(height: 8.0),
          // Referencia
          TextFormField(
            enabled: widget.editMode,
            initialValue: familia.endReferencia,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            minLines: 2,
            maxLines: 4,
            textAlignVertical: TextAlignVertical.top,
            textInputAction: TextInputAction.next,
            decoration: mTextFieldDecoration.copyWith(labelText: 'Referência'),
            onChanged: (value) {
              familia.endReferencia = value;
            },
          ),
          const SizedBox(height: 24.0),
          const Text(
            'ANALISE SOCIAL',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              // Renda Media
              Expanded(
                flex: 1,
                child: TextFormField(
                  enabled: widget.editMode,
                  initialValue: maskCurrency.format(familia.famRendaMedia),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter()
                  ],
                  textInputAction: TextInputAction.next,
                  decoration: mTextFieldDecoration.copyWith(
                      labelText: 'Renda Média', prefixText: 'R\$ '),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      familia.famRendaMedia = 0;
                    } else {
                      familia.famRendaMedia = maskCurrency.parse(value);
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
                  value: familia.famBeneficioGov,
                  iconDisabledColor: Colors.transparent,
                  decoration: mTextFieldDecoration.copyWith(
                    labelText: 'Benefício do governo',
                    isDense: true,
                    enabled: widget.editMode,
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
                  onChanged: widget.editMode
                      ? (value) {
                          setState(() {
                            familia.famBeneficioGov = value!;
                          });
                        }
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          const Text(
            'CONTROLE IPBFoz',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          // Informacao Extra
          TextFormField(
            enabled: widget.editMode,
            initialValue: familia.extraInfo,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.next,
            minLines: 5,
            maxLines: 8,
            textAlignVertical: TextAlignVertical.top,
            decoration:
                mTextFieldDecoration.copyWith(labelText: 'Informações extras'),
            onChanged: (value) {
              familia.extraInfo = value;
            },
          ),
          const SizedBox(height: 8.0),
          // Solicitante
          TextFormField(
            enabled: widget.editMode,
            initialValue: familia.cadSolicitante,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            decoration: mTextFieldDecoration.copyWith(labelText: 'Solicitante'),
            onChanged: (value) {
              familia.cadSolicitante = value;
            },
          ),
          const SizedBox(height: 8.0),
          // Diacono Responsavel (combo box)
          DropdownButtonFormField<String>(
            value: familia.cadDiacono,
            iconDisabledColor: Colors.transparent,
            decoration: mTextFieldDecoration.copyWith(
              labelText: 'Diácono responsável',
              isDense: true,
              enabled: widget.editMode,
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
            onChanged: widget.editMode
                ? (value) {
                    setState(() {
                      familia.cadDiacono = value!.toString();
                    });
                  }
                : null,
          ),
          const SizedBox(height: 36.0),
          Row(
            children: [
              onFirestore
                  ? Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        label: Text(familia.cadAtivo
                            ? 'Desativar cadastro'
                            : 'Reativar cadastro'),
                        icon: const Icon(Icons.archive_rounded),
                        style:
                            mOutlinedButtonStyle.merge(OutlinedButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.red,
                        )),
                        onPressed: widget.editMode
                            ? () {
                                if (familia.cadAtivo) {
                                  reference.update({'cadAtivo': false});
                                } else {
                                  reference.update({'cadAtivo': true});
                                }
                                familia.cadAtivo = !familia.cadAtivo;
                                setState(() {});
                              }
                            : null,
                      ),
                    )
                  : const SizedBox(),
              const Expanded(flex: 1, child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}
