import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:easy_mask/easy_mask.dart';

class Estilos {
  /// Para titulos
  static TextStyle titulo = TextStyle(
      color: Colors.grey.shade800, fontSize: 18, fontWeight: FontWeight.bold);

  /// Para destaques
  static TextStyle destaque =
      const TextStyle(color: Colors.red, fontWeight: FontWeight.bold);

  /// Para legendas
  static TextStyle legenda = const TextStyle(color: Colors.grey, fontSize: 11);

  static InputDecoration mInputDecoration = const InputDecoration(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      disabledBorder: OutlineInputBorder(borderSide: BorderSide.none));
}

var inputPhone =
    TextInputMask(mask: ['(99) 9999-9999', '(99) 99999-9999'], reverse: false);
var maskPhone = MagicMask.buildMask(inputPhone.mask);

var inputCEP = TextInputMask(mask: '99999-999', reverse: false);
var maskCEP = MagicMask.buildMask(inputCEP.mask);

var inputCurrency = TextInputMask(mask: '9+.999,99', reverse: true);
var maskCurrency =
    NumberFormat.currency(locale: 'pt_BR', customPattern: '###,###.##');

var inputDate =
    TextInputMask(mask: '99/99/9999', placeholder: 'x', maxPlaceHolders: 10);
var maskDate = DateFormat('dd/MM/yyyy');

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
  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
  visualDensity: VisualDensity.standard,
  shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16.0))),
);

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.parse(newValue.text);

    String newText = maskCurrency.format(value / 100);

    return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length));
  }
}
