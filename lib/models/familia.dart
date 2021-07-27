import '/models/morador.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Familia {
  late bool cadAtivo;
  late String cadDiacono; // auto
  late Timestamp cadData; // auto
  late String cadSolicitante;
  late int cadEntregas; // auto

  late int famResponsavel;
  late String famFoto;
  late int famTelefone1;
  late int famTelefone2;
  late num famRendaMedia;
  late int famBeneficioGov;

  late GeoPoint endGeopoint;
  late int endCEP;
  late String endLogradouro;
  late String endNumero;
  late String endBairro;
  late String endCidade;
  late String endEstado;
  late String endPais;
  late String endReferencia;

  late String extraInfo;

  late List<Morador> moradores; // 1 item OBRIGATORIO

  Familia({
    required this.cadAtivo,
    required this.cadDiacono,
    required this.cadData,
    required this.cadSolicitante,
    required this.cadEntregas,
    required this.famResponsavel,
    required this.famFoto,
    required this.famTelefone1,
    required this.famTelefone2,
    required this.famRendaMedia,
    required this.famBeneficioGov,
    required this.endGeopoint,
    required this.endCEP,
    required this.endLogradouro,
    required this.endNumero,
    required this.endBairro,
    required this.endCidade,
    required this.endEstado,
    required this.endPais,
    required this.endReferencia,
    required this.extraInfo,
    required this.moradores,
  });

  Familia.fromJson(Map<String, Object?> json)
      : this(
          cadAtivo: (json['cadAtivo'] ?? true) as bool,
          cadDiacono: (json['cadDiacono'] ?? '') as String,
          cadData: (json['cadData'] ?? Timestamp.fromDate(DateTime.now()))
              as Timestamp,
          cadSolicitante: (json['cadSolicitante'] ?? '') as String,
          cadEntregas: (json['cadEntregas'] ?? 0) as int,
          famResponsavel: (json['famResponsavel'] ?? 0) as int,
          famFoto: (json['famFoto'] ?? '') as String,
          famTelefone1: (json['famTelefone1'] ?? 450) as int,
          famTelefone2: (json['famTelefone2'] ?? 450) as int,
          famRendaMedia: (json['famRendaMedia'] ?? 0) as num,
          famBeneficioGov: (json['famBeneficioGov'] ?? 0) as int,
          endGeopoint: (json['endGeopoint'] ??
              new GeoPoint(-25.5322523, -54.5864979)) as GeoPoint,
          endCEP: (json['endCEP'] ?? 85852000) as int,
          endLogradouro: (json['endLogradouro'] ?? '') as String,
          endNumero: (json['endNumero'] ?? '') as String,
          endBairro: (json['endBairro'] ?? '') as String,
          endCidade: (json['endCidade'] ?? 'Foz do Iguaçu') as String,
          endEstado: (json['endEstado'] ?? 'PR') as String,
          endPais: (json['endPais'] ?? 'Brasil') as String,
          endReferencia: (json['endReferencia'] ?? '') as String,
          extraInfo: (json['extraInfo'] ?? '') as String,
          moradores: List<Morador>.from(
              ((json['moradores'] ?? null) as List<dynamic>)
                  .map((e) => Morador.fromJson(e))),
        );

  Map<String, Object?> extractMap(Map<String, Object?>? json) {
    if (json == null) {
      json = new Map<String, Object?>();
    }
    return json;
  }

  Map<String, Object?> toJson() {
    return {
      'cadAtivo': cadAtivo,
      'cadDiacono': cadDiacono,
      'cadData': cadData,
      'cadSolicitante': cadSolicitante,
      'cadEntregas': cadEntregas,
      'famResponsavel': famResponsavel,
      'famFoto': famFoto,
      'famTelefone1': famTelefone1,
      'famTelefone2': famTelefone2,
      'famRendaMedia': famRendaMedia,
      'famBeneficioGov': famBeneficioGov,
      'endGeopoint': endGeopoint,
      'endCEP': endCEP,
      'endLogradouro': endLogradouro,
      'endNumero': endNumero,
      'endBairro': endBairro,
      'endCidade': endCidade,
      'endEstado': endEstado,
      'endPais': endPais,
      'endReferencia': endReferencia,
      'extraInfo': extraInfo,
      'moradores':
          List<dynamic>.from(moradores.map((morador) => morador.toJson())),
    };
  }
}
