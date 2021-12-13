import 'package:acao_ipbfoz/utils/util.dart';
import 'package:flutter/foundation.dart';
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

  /// Apresenta um bottom dialog padrão com o título e conteúdo definido
  static void bottomDialog({
    required BuildContext context,
    required String titulo,
    required Widget conteudo,
    IconData? icon,
    ScrollController? scrollController,
    VoidCallback? onPressed,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.3,
          maxHeight: MediaQuery.of(context).size.height * 0.9),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewInsets.top,
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: Util.paddingListH(context),
            right: Util.paddingListH(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Elemento grafico (indicador de dialog)
              Container(
                width: 64,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  color: Colors.black38,
                ),
              ),
              // Cabeçalho
              Row(
                children: [
                  IconButton(
                    onPressed: null,
                    icon: Icon(icon ?? Icons.subtitles, color: Colors.teal),
                  ),
                  Expanded(
                    child: Text(
                      titulo,
                      textAlign: TextAlign.center,
                      style: Estilos.titulo,
                    ),
                  ),
                  const CloseButton(color: Colors.black38),
                ],
              ),
              // Conteúdo
              Flexible(child: conteudo),
            ],
          ),
        );
      },
    ).then((value) {
      if (onPressed != null) onPressed();
    });
  }
}
