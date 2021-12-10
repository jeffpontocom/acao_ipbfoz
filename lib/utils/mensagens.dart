import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'estilos.dart';

class Mensagem {
  // Variáveis Globais
  static const double _alertMaxWidth = 360;

  /// Apresenta popup com uma mensagem simples
  static void simples(
      {required BuildContext context,
      String? titulo,
      String? mensagem,
      ValueNotifier? notificacao,
      VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo ?? 'Mensagem'),
          titleTextStyle: Estilos.titulo,
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _alertMaxWidth),
            child: Text(
                mensagem ?? notificacao?.value ?? 'Sua atenção foi requerida!'),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Modular.to.maybePop();
                if (onPressed != null) {
                  onPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Apresenta popup de alerta
  static void decisao(
      {required BuildContext context,
      required String titulo,
      required String mensagem,
      Widget? extra,
      required Function(bool) onPressed}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _alertMaxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mensagem),
                extra ?? const SizedBox(),
              ],
            ),
          ),
          //buttonPadding: const EdgeInsets.all(0),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 12),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              child: const Text(
                'CANCELAR',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Modular.to.pop(); // Fecha o dialogo
                onPressed(false);
              },
            ),
            TextButton(
              child: const Text('SIM'),
              onPressed: () {
                Modular.to.pop(); // Fecha o dialogo
                onPressed(true);
              },
            ),
          ],
        );
      },
    );
  }

  /// Apresenta popup com indicador de execução
  static void aguardar(
      {required BuildContext context,
      String? titulo,
      String? mensagem,
      ValueNotifier? notificacao}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(24),
          title: Text(titulo ?? 'Aguarde'),
          titleTextStyle: Estilos.titulo,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _alertMaxWidth),
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  Text(mensagem ?? notificacao?.value ?? 'Executando...'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
