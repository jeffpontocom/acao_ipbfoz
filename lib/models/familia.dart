import '/models/diacono.dart';
import '/models/morador.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Familia {
  late bool cadAtivo;
  late String cadDiacono; // OBRIGATORIO
  late Timestamp cadData; // OBRIGATORIO
  late String cadSolicitante;

  late int famResponsavel;
  late String famFoto;
  late int famTelefone1; // OBRIGATORIO
  late int famTelefone2;
  late int famRendaMedia;
  late int famBeneficioGov;

  late GeoPoint endGeopoint;
  late int endCEP; // OBRIGATORIO
  late String endLogradouro;
  late String endNumero; // OBRIGATORIO
  late String endBairro;
  late String endReferencia;

  late String extraInfo;

  late List<Morador> moradores; // 1 item OBRIGATORIO

  Familia({
    required this.cadAtivo,
    required this.cadDiacono,
    required this.cadData,
    required this.cadSolicitante,
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
          famResponsavel: (json['famResponsavel'] ?? 0) as int,
          famFoto: (json['famFoto'] ?? '') as String,
          famTelefone1: (json['famTelefone1'] ?? 0) as int,
          famTelefone2: (json['famTelefone2'] ?? 0) as int,
          famRendaMedia: (json['famRendaMedia'] ?? 0) as int,
          famBeneficioGov: (json['famBeneficioGov'] ?? 0) as int,
          endGeopoint: (json['endGeopoint'] ??
              new GeoPoint(-25.5322523, -54.5864979)) as GeoPoint,
          endCEP: (json['endCEP'] ?? 85852000) as int,
          endLogradouro: (json['endLogradouro'] ?? '') as String,
          endNumero: (json['endNumero'] ?? '') as String,
          endBairro: (json['endBairro'] ?? '') as String,
          endReferencia: (json['endReferencia'] ?? '') as String,
          extraInfo: (json['extraInfo'] ?? '') as String,
          moradores:
              (json['moradores'] ?? new List<Morador>.empty()) as List<Morador>,
        );

  Map<String, Object?> toJson() {
    return {
      'cadAtivo': cadAtivo,
      'cadDiacono': cadDiacono,
      'cadData': cadData,
      'cadSolicitante': cadSolicitante,
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
      'endReferencia': endReferencia,
      'extraInfo': extraInfo,
      'moradores': moradores,
    };
  }

  Familia.novaFamilia()
      : this(
            cadAtivo: true,
            cadDiacono: Diacono.instance.uid,
            cadData: Timestamp.now(),
            cadSolicitante: '',
            famResponsavel: 0,
            famFoto: '',
            famTelefone1: 0,
            famTelefone2: 0,
            famRendaMedia: 0,
            famBeneficioGov: 0,
            endGeopoint: new GeoPoint(-25.5322523, -54.5864979),
            endCEP: 85852000,
            endLogradouro: '',
            endNumero: '',
            endBairro: '',
            endReferencia: '',
            extraInfo: '',
            moradores: new List<Morador>.empty());
}
