import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

var phoneMask = new MaskTextInputFormatter(mask: '(##) ####-####');
var cellMask = new MaskTextInputFormatter(mask: '(##) #####-####');
var cepMask = new MaskTextInputFormatter(mask: '#####-###');
var dateMask = new MaskTextInputFormatter(mask: '##/##/####');

// INTERFACE PADRÃO para caixas de texto
const mTextFieldDecoration = InputDecoration(
  isDense: false,
  hintStyle: TextStyle(color: Colors.grey),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlue, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
  disabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
);

ButtonStyle mOutlinedButtonStyle = OutlinedButton.styleFrom(
  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
  visualDensity: VisualDensity.standard,
  shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16.0))),
);
