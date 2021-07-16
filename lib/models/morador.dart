import 'package:cloud_firestore/cloud_firestore.dart';

class Morador {
  final String nome; // OBRIGATORIO
  final Timestamp nascimento; // OBRIGATORIO
  final int escolaridade;
  final String profissao;
  final bool especial;

  Morador({
    required this.nome,
    required this.nascimento,
    required this.escolaridade,
    required this.profissao,
    required this.especial,
  });

  Morador.fromJson(Map<String, Object?> json)
      : this(
          nome: (json['nome'] ?? '') as String,
          nascimento: (json['nascimento'] ??
              Timestamp.fromDate(DateTime.parse('2000-01-01'))) as Timestamp,
          escolaridade: (json['escolaridade'] ?? 0) as int,
          profissao: (json['profissao'] ?? '') as String,
          especial: (json['especial'] ?? false) as bool,
        );

  Map<String, Object?> toJson() {
    return {
      'nome': nome,
      'nascimento': nascimento,
      'escolaridade': escolaridade,
      'profissao': profissao,
      'especial': especial
    };
  }
}
