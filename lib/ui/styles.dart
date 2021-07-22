import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:easy_mask/easy_mask.dart';

var inputPhone = new TextInputMask(
    mask: ['(99) 9999-9999', '(99) 99999-9999'], reverse: false);
var maskPhone = new MagicMask.buildMask(inputPhone.mask);

var inputCEP = new TextInputMask(mask: '99999-999', reverse: false);
var maskCEP = new MagicMask.buildMask(inputCEP.mask);

var inputCurrency = new TextInputMask(mask: '9+.999,99', reverse: true);
var maskCurrency =
    new NumberFormat.currency(locale: 'pt_BR', customPattern: '###,###.##');

var inputDate = new TextInputMask(mask: '99/99/9999');
var maskDate = new DateFormat('dd/MM/yyyy');

// INTERFACE PADRÃO para caixas de texto
const mTextFieldDecoration = InputDecoration(
  isDense: false,
  hintStyle: TextStyle(color: Colors.grey),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
  disabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
);

ButtonStyle mOutlinedButtonStyle = OutlinedButton.styleFrom(
  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
  visualDensity: VisualDensity.standard,
  shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16.0))),
);

class CurrencyInputFormatter extends TextInputFormatter {
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      print(true);
      return newValue;
    }

    double value = double.parse(newValue.text);

    String newText = maskCurrency.format(value / 100);

    return newValue.copyWith(
        text: newText,
        selection: new TextSelection.collapsed(offset: newText.length));
  }
}
