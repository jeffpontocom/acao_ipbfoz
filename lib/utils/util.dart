import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Util {
  Util();

  /// Formato de data e hora no padrão brasileiro "1 de janeiro de 2020 23:59:59."
  static final DateFormat mDateTimeFormat =
      DateFormat.yMMMMd('pt_BR').add_Hms();

  /// Formato de data no padrão brasileiro "1 de janeiro de 2020."
  static final DateFormat mDateFormat = DateFormat.yMMMMd('pt_BR');

  /// Formato de data no padrão brasileiro "01/01/2020."
  static final DateFormat mDateFormatShort = DateFormat.yMd('pt_BR');

  /// Formato de numeros com separador de milhar
  static final NumberFormat mNumFormat = NumberFormat.decimalPattern('pt_BR');

  /// Verifica se o teclado virtual está presente na tela
  static bool isKeyboardOpen(context) {
    return MediaQuery.of(context).viewInsets.bottom != 0;
  }

  /// Margem ou Padding vertical padrão (min 12)
  static double margemV(context) {
    double minPad = 12;
    var mesure = ((MediaQuery.of(context).size.height - 860) / 2) + minPad;
    return mesure > minPad ? mesure : minPad;
  }

  /// Margem ou Padding horizontal padrão (min 32)
  static double margemH(context) {
    double minPad = 24;
    var mesure = ((MediaQuery.of(context).size.width - 860) / 2) + minPad;
    return mesure > minPad ? mesure : minPad;
  }

  /// Margem ou Padding horizontal padrão (min 32)
  static double paddingListH(context) {
    double minPad = 0;
    var mesure = ((MediaQuery.of(context).size.width - 860) / 2) + minPad;
    return mesure > minPad ? mesure : minPad;
  }

  /// Validar texto tipo e-mail
  static String? validarEmail(String? value) {
    if (value != null) {
      final regExp = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
      if (regExp.hasMatch(value)) return null;
      return 'Informe um e-mail válido';
    }
  }

  /// Validar senha com no mínimo 5 caracteres
  static String? validarSenha(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length >= 5) {
        return null;
      }
      return 'A senha deve ter no mínimo 5 caracteres';
    }
  }
}
