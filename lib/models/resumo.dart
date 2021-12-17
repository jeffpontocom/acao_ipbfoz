import 'package:acao_ipbfoz/models/entrega.dart';

class Resumo {
  static const String colecao = 'resumos';

  /// Numero de familias com cadastro ativo
  int? resumoFamiliasAtivas;

  /// Total de entregas separadas por Ano / Mes
  List<ResumoEntregas>? resumoEntregas;

  Resumo({
    this.resumoFamiliasAtivas,
    required this.resumoEntregas,
  });

  Resumo.fromJson(Map<String, dynamic> json)
      : this(
          resumoFamiliasAtivas: (json['resumoFamiliasAtivas'] ?? 0) as int,
          resumoEntregas: List<ResumoEntregas>.from(
              (((json['resumoEntregas']) ?? []) as List<dynamic>)
                  .map((e) => ResumoEntregas.fromJson(e))),
        );

  Map<String, dynamic> toJson() {
    return {
      'resumoFamiliasAtivas': resumoFamiliasAtivas,
      'resumoEntregas': List<dynamic>.from(
          resumoEntregas?.map((entregas) => entregas.toJson()) ?? []),
    };
  }
}
