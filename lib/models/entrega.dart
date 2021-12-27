import 'package:cloud_firestore/cloud_firestore.dart';

/// Classe para registro das entregas
class Entrega {
  late Timestamp data;
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
          itens: List<ItensEntrega>.from(((json['itens']) as List<dynamic>)
              .map((e) => ItensEntrega.fromJson(e))),
          entregue: (json['entregue'] ?? false) as bool,
        );

  Map<String, Object?> toJson() {
    return {
      'data': data,
      'diacono': diacono,
      'itens': List<dynamic>.from(itens.map((item) => item.toJson())),
      'entregue': entregue
    };
  }
}

/// Classe para registro dos itens das entregas
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
          validade: (json['validade'] ?? Timestamp.fromDate(DateTime(2000)))
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

/// Classe para registro do total de entregas mensais
class ResumoEntregas {
  late int ano;
  late int mes;
  late int total;

  ResumoEntregas({required this.ano, required this.mes, required this.total});

  ResumoEntregas.fromJson(Map<String, dynamic> json)
      : this(
          ano: (json['ano'] ?? 0) as int,
          mes: (json['mes'] ?? 0) as int,
          total: (json['total'] ?? 0) as int,
        );

  Map<String, dynamic> toJson() {
    return {
      'ano': ano,
      'mes': mes,
      'total': total,
    };
  }

  void increment() => total++;

  void clear() => total = 0;
}
