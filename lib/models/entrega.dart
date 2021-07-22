import 'package:acao_ipbfoz/models/entrega_itens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Entrega {
  late Timestamp data; // OBRIGATORIO
  late String diacono;
  late List<ItensEntrega> itens;
  late bool entregue;

  Entrega(
      {required this.data,
      required this.diacono,
      required this.itens,
      required this.entregue});

  Entrega.fromJson(Map<String, Object?> json)
      : this(
          data:
              (json['data'] ?? Timestamp.fromDate(DateTime.now())) as Timestamp,
          diacono: (json['diacono'] ?? '') as String,
          itens: List<ItensEntrega>.from(
              ((json['itens'] ?? null) as List<dynamic>)
                  .map((e) => ItensEntrega.fromJson(e))),
          entregue: (json['entregue'] ?? false) as bool,
        );

  Map<String, Object?> toJson() {
    return {
      'data': data,
      'diacono': diacono,
      'itens': List<dynamic>.from(itens.map((e) => e.toJson())),
      'entregue': entregue
    };
  }
}
