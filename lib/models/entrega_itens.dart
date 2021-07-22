import 'package:cloud_firestore/cloud_firestore.dart';

class ItensEntrega {
  late int quantidade;
  late String descricao;
  late Timestamp validade;

  ItensEntrega({
    required this.quantidade,
    required this.descricao,
    required this.validade,
  });

  ItensEntrega.fromJson(Map<String, Object?> json)
      : this(
          quantidade: (json['quantidade'] ?? 1) as int,
          descricao: (json['descricao'] ?? '') as String,
          validade: (json['validade'] ?? Timestamp.fromDate(DateTime(1800)))
              as Timestamp,
        );

  Map<String, Object?> toJson() {
    return {
      'quantidade': quantidade,
      'descricao': descricao,
      'validade': validade,
    };
  }
}
