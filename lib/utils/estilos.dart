import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Classe para estilos do app
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

/// Classe para mascaras de texto
class Inputs {
  /// Para Telefones (formato (##) _####-####)
  static var textoFone = TextInputMask(
      mask: ['(99) 9999-9999', '(99) 99999-9999'], reverse: false);
  static var mascaraFone = MagicMask.buildMask(textoFone.mask);

  /// Para CEPs (formato #####-###)
  static var textoCEP = TextInputMask(mask: '99999-999', reverse: false);
  static var mascaraCEP = MagicMask.buildMask(textoCEP.mask);

  /// Para moeda (formato #.###,##)
  static var textoMoeda = TextInputMask(mask: '9+.999,99', reverse: true);
  static var mascaraMoeda =
      NumberFormat.currency(locale: 'pt_BR', customPattern: '###,###.##');

  /// Para datas (formato dd/MM/yyyy)
  static var textoData =
      TextInputMask(mask: '99/99/9999', placeholder: 'x', maxPlaceHolders: 10);
  static var mascaraData = DateFormat('dd/MM/yyyy');
}

/// Classe para input em formato de moedas
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.parse(newValue.text);

    String newText = Inputs.mascaraMoeda.format(value / 100);

    return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length));
  }
}
