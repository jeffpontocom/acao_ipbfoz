import 'package:cloud_firestore/cloud_firestore.dart';

class Entrega {
  final Timestamp data; // OBRIGATORIO
  final String diacono;
  final List<String> itens;

  Entrega({
    required this.data,
    required this.diacono,
    required this.itens,
  });

  Entrega.fromJson(Map<String, Object?> json)
      : this(
          data:
              (json['data'] ?? Timestamp.fromDate(DateTime.now())) as Timestamp,
          diacono: (json['diacono'] ?? '') as String,
          itens: (json['itens'] ?? List<String>.empty()) as List<String>,
        );

  Map<String, Object?> toJson() {
    return {
      'data': data,
      'diacono': diacono,
      'itens': itens,
    };
  }
}
