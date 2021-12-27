import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/morador.dart';

class Familia {
  late bool cadAtivo; // OBRIGATORIO
  late Timestamp cadData; // auto
  late String cadDiacono; // auto
  late String cadNomeFamilia; // OBRIGATORIO
  String? cadSolicitante;
  bool? cadParticipante;

  String? famFoto;
  int? famTelefone1;
  int? famTelefone2;
  num? famRendaMedia;
  int? famBeneficioGov;

  GeoPoint? endGeopoint;
  int? endCEP;
  String? endLogradouro;
  String? endNumero;
  String? endBairro;
  String? endCidade;
  String? endEstado;
  String? endPais;
  String? endReferencia;

  String? extraInfo;

  late List<Morador> moradores; // 1 item OBRIGATORIO

  int? cadEntregas; // @deprecar
  int? famResponsavel; // @deprecar

  Familia({
    required this.cadAtivo,
    required this.cadDiacono,
    required this.cadData,
    required this.cadNomeFamilia,
    this.cadSolicitante,
    this.cadParticipante,
    this.famFoto,
    this.famTelefone1,
    this.famTelefone2,
    this.famRendaMedia,
    this.famBeneficioGov,
    this.endGeopoint,
    this.endCEP,
    this.endLogradouro,
    this.endNumero,
    this.endBairro,
    this.endCidade,
    this.endEstado,
    this.endPais,
    this.endReferencia,
    this.extraInfo,
    required this.moradores,
    this.cadEntregas, // @deprecar
    this.famResponsavel, // @deprecar
  });

  Familia.fromJson(Map<String, dynamic> json)
      : this(
          cadAtivo: (json['cadAtivo'] ?? true) as bool,
          cadDiacono: (json['cadDiacono'] ?? '') as String,
          cadData: (json['cadData'] ?? Timestamp.fromDate(DateTime.now()))
              as Timestamp,
          cadNomeFamilia:
              (json['cadNomeFamilia'] ?? '[Não definido]') as String,
          cadSolicitante: (json['cadSolicitante'] ?? '') as String,
          cadParticipante: (json['cadParticipante'] ?? false) as bool,
          famFoto: (json['famFoto'] ?? '') as String,
          famTelefone1: (json['famTelefone1'] ?? 0) as int,
          famTelefone2: (json['famTelefone2'] ?? 0) as int,
          famRendaMedia: (json['famRendaMedia'] ?? 0) as num,
          famBeneficioGov: (json['famBeneficioGov'] ?? 0) as int,
          endGeopoint: (json['endGeopoint'] ??
              const GeoPoint(-25.5322523, -54.5864979)) as GeoPoint,
          endCEP: (json['endCEP'] ?? 0) as int,
          endLogradouro: (json['endLogradouro'] ?? '') as String,
          endNumero: (json['endNumero'] ?? '') as String,
          endBairro: (json['endBairro'] ?? '') as String,
          endCidade: (json['endCidade'] ?? 'Foz do Iguaçu') as String,
          endEstado: (json['endEstado'] ?? 'PR') as String,
          endPais: (json['endPais'] ?? 'Brasil') as String,
          endReferencia: (json['endReferencia'] ?? '') as String,
          extraInfo: (json['extraInfo'] ?? '') as String,
          moradores: List<Morador>.from(((json['moradores']) as List<dynamic>)
              .map((e) => Morador.fromJson(e))),
          cadEntregas: (json['cadEntregas'] ?? 0) as int, //@deprecar
          famResponsavel: (json['famResponsavel'] ?? 0) as int, //@deprecar
        );

  Map<String, Object?> extractMap(Map<String, Object?>? json) {
    json ??= <String, Object?>{};
    return json;
  }

  Map<String, dynamic> toJson() {
    return {
      'cadAtivo': cadAtivo,
      'cadDiacono': cadDiacono,
      'cadData': cadData,
      'cadNomeFamilia': cadNomeFamilia,
      'cadSolicitante': cadSolicitante,
      'cadParticipante': cadParticipante,
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
      'cadEntregas': cadEntregas, // @deprecar
      'famResponsavel': famResponsavel, // @deprecar
    };
  }
}
