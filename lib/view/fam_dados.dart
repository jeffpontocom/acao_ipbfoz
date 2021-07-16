import 'package:acao_ipbfoz/view/familia_page.dart';

import '/models/familia.dart';
import '/ui/decoration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FamiliaDados extends StatefulWidget {
  FamiliaDados(this.reference, this.editMode);
  final DocumentReference<Familia> reference;
  final bool editMode;

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
            enabled: widget.editMode,
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
                  enabled: widget.editMode,
                  decoration:
                      mTextFieldDecoration.copyWith(labelText: 'Whatsapp'),
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
                  enabled: widget.editMode,
                  decoration: mTextFieldDecoration.copyWith(
                      labelText: 'Telefone (outro)'),
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
                  enabled: widget.editMode,
                  decoration: mTextFieldDecoration.copyWith(labelText: 'CEP'),
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
                  enabled: widget.editMode,
                  decoration:
                      mTextFieldDecoration.copyWith(labelText: 'Número'),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          // Logradouro
          TextFormField(
            enabled: widget.editMode,
            decoration: mTextFieldDecoration.copyWith(labelText: 'Logradouro'),
          ),
          SizedBox(
            height: 8.0,
          ),
          // Bairro
          TextFormField(
            enabled: widget.editMode,
            decoration: mTextFieldDecoration.copyWith(labelText: 'Bairro'),
          ),
          SizedBox(
            height: 8.0,
          ),
          // Referencia
          TextFormField(
            enabled: widget.editMode,
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
            enabled: widget.editMode,
            decoration: mTextFieldDecoration.copyWith(labelText: 'Renda Média'),
          ),
          SizedBox(
            height: 8.0,
          ),
          // Beneficio Governo (combo box)
          TextFormField(
            enabled: widget.editMode,
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
            enabled: widget.editMode,
            initialValue: familia.extraInfo,
            decoration:
                mTextFieldDecoration.copyWith(labelText: 'Informação Extra'),
          ),
          SizedBox(
            height: 8.0,
          ),
          // Solicitante
          TextFormField(
            enabled: widget.editMode,
            initialValue: familia.cadSolicitante,
            decoration: mTextFieldDecoration.copyWith(labelText: 'Solicitante'),
          ),
          SizedBox(
            height: 8.0,
          ),
          // Diacono Responsavel (combo box)
          TextFormField(
            enabled: widget.editMode,
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
