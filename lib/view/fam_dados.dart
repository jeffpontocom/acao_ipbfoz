import 'package:flutter/services.dart';

import 'familia_page.dart';

import '../ui/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FamiliaDados extends StatefulWidget {
  FamiliaDados();

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
        padding: EdgeInsets.all(24.0),
        children: [
          Text(
            'CADASTRO EM EDIÇÃO',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '' + DateFormat.yMMMMd('pt_BR').format(familia.cadData.toDate()),
          ),
          SizedBox(
            height: 24.0,
          ),

          Text(
            'CONTATO',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8.0,
          ),
          // Familiar responsável (combo box)
          DropdownButtonFormField<int>(
            value: familia.famResponsavel,
            decoration: mTextFieldDecoration.copyWith(
                labelText: 'Familiar responsável', isDense: true),
            items: familia.moradores
                .map(
                  (morador) => new DropdownMenuItem(
                    value: familia.moradores.indexOf(morador),
                    child: new Text(morador.nome),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                familia.famResponsavel = value!;
              });
            },
          ),
          SizedBox(
            height: 8.0,
          ),
          Row(
            children: [
              // Whatsapp
              Expanded(
                flex: 1,
                child: TextFormField(
                  enabled: editMode,
                  initialValue: familia.famTelefone1 == 0
                      ? ''
                      : cellMask.maskText(familia.famTelefone1.toString()),
                  inputFormatters: [cellMask],
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration:
                      mTextFieldDecoration.copyWith(labelText: 'Whatsapp'),
                  onChanged: (value) {
                    //print('Caracteres: ' + value.length.toString());
                    familia.famTelefone1 =
                        int.parse(cellMask.getUnmaskedText());
                  },
                ),
              ),
              Expanded(
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
                  initialValue: familia.famTelefone2 == 0
                      ? ''
                      : cellMask.maskText(familia.famTelefone2.toString()),
                  inputFormatters: [cellMask],
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: mTextFieldDecoration.copyWith(
                      labelText: 'Telefone (outro)'),
                  onChanged: (value) {
                    familia.famTelefone2 =
                        int.parse(cellMask.getUnmaskedText());
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 24.0,
          ),
          Text(
            'ENDEREÇO',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8.0,
          ),
          Row(
            children: [
              // CEP
              Expanded(
                flex: 1,
                child: TextFormField(
                  enabled: editMode,
                  initialValue: cepMask.maskText(familia.endCEP.toString()),
                  inputFormatters: [cepMask],
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: mTextFieldDecoration.copyWith(labelText: 'CEP'),
                  onChanged: (value) {
                    familia.endCEP = int.parse(cepMask.getUnmaskedText());
                  },
                ),
              ),
              Expanded(
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
                  initialValue: familia.endNumero,
                  keyboardType: TextInputType.datetime,
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
          SizedBox(
            height: 8.0,
          ),
          // Logradouro
          TextFormField(
            enabled: editMode,
            initialValue: familia.endLogradouro,
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.next,
            decoration: mTextFieldDecoration.copyWith(labelText: 'Logradouro'),
            onChanged: (value) {
              familia.endLogradouro = value;
            },
          ),
          SizedBox(
            height: 8.0,
          ),
          // Bairro
          TextFormField(
            enabled: editMode,
            decoration: mTextFieldDecoration.copyWith(labelText: 'Bairro'),
            onChanged: (value) {
              familia.endBairro = value;
            },
          ),
          SizedBox(
            height: 8.0,
          ),
          // Referencia
          TextFormField(
            enabled: editMode,
            decoration: mTextFieldDecoration.copyWith(labelText: 'Referência'),
            onChanged: (value) {
              familia.endReferencia = value;
            },
          ),
          SizedBox(
            height: 24.0,
          ),

          Text(
            'ANALISE SOCIAL',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8.0,
          ),
          // Renda Media
          TextFormField(
            enabled: editMode,
            decoration: mTextFieldDecoration.copyWith(labelText: 'Renda Média'),
            onChanged: (value) {
              familia.famRendaMedia = int.parse(value);
            },
          ),
          SizedBox(
            height: 8.0,
          ),
          // Beneficio Governo (combo box)
          TextFormField(
            enabled: editMode,
            decoration: mTextFieldDecoration.copyWith(
                labelText: 'Benefício do governo'),
            onChanged: (value) {
              familia.famBeneficioGov = int.parse(value);
            },
          ),
          SizedBox(
            height: 24.0,
          ),

          Text(
            'CONTROLE IPBFoz',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8.0,
          ),
          // Informacao Extra
          TextFormField(
            enabled: editMode,
            initialValue: familia.extraInfo,
            decoration:
                mTextFieldDecoration.copyWith(labelText: 'Informação Extra'),
            onChanged: (value) {
              familia.extraInfo = value;
            },
          ),
          SizedBox(
            height: 8.0,
          ),
          // Solicitante
          TextFormField(
            enabled: editMode,
            initialValue: familia.cadSolicitante,
            decoration: mTextFieldDecoration.copyWith(labelText: 'Solicitante'),
            onChanged: (value) {
              familia.cadSolicitante = value;
            },
          ),
          SizedBox(
            height: 8.0,
          ),
          // Diacono Responsavel (combo box)
          TextFormField(
            enabled: editMode,
            initialValue: familia.cadDiacono,
            decoration:
                mTextFieldDecoration.copyWith(labelText: 'Diácono responsável'),
            onChanged: (value) {
              familia.cadDiacono = value;
            },
          ),
          SizedBox(
            height: 8.0,
          ),
        ],
      ),
    );
  }
}
