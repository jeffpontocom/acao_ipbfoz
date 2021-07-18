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
            'CADASTRO ATIVO',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Realizado em ' +
                DateFormat.yMMMMd('pt_BR').format(familia.cadData.toDate()),
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
          TextFormField(
            enabled: editMode,
            decoration: mTextFieldDecoration.copyWith(
                labelText: 'Familiar responsável'),
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
                  initialValue:
                      phoneMask.maskText(familia.famTelefone1.toString()),
                  inputFormatters: [phoneMask],
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration:
                      mTextFieldDecoration.copyWith(labelText: 'Whatsapp'),
                  onChanged: (value) {
                    familia.famTelefone1 =
                        int.parse(phoneMask.getUnmaskedText());
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
                  initialValue:
                      phoneMask.maskText(familia.famTelefone2.toString()),
                  inputFormatters: [phoneMask],
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: mTextFieldDecoration.copyWith(
                      labelText: 'Telefone (outro)'),
                  onChanged: (value) {
                    familia.famTelefone2 =
                        int.parse(phoneMask.getUnmaskedText());
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
          ),
          SizedBox(
            height: 8.0,
          ),
          // Referencia
          TextFormField(
            enabled: editMode,
            decoration: mTextFieldDecoration.copyWith(labelText: 'Referência'),
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
          ),
          SizedBox(
            height: 8.0,
          ),
          // Beneficio Governo (combo box)
          TextFormField(
            enabled: editMode,
            decoration: mTextFieldDecoration.copyWith(
                labelText: 'Benefício do governo'),
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
          ),
          SizedBox(
            height: 8.0,
          ),
          // Solicitante
          TextFormField(
            enabled: editMode,
            initialValue: familia.cadSolicitante,
            decoration: mTextFieldDecoration.copyWith(labelText: 'Solicitante'),
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
          ),
          SizedBox(
            height: 8.0,
          ),
        ],
      ),
    );
  }
}
