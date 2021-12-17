import 'dart:developer' as dev;

import 'package:acao_ipbfoz/models/familia.dart';
import 'package:acao_ipbfoz/models/morador.dart';
import 'package:acao_ipbfoz/models/resumo.dart';
import 'package:acao_ipbfoz/utils/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '/models/entrega.dart';
import '/utils/mensagens.dart';

class Funcao {
  /// Atualizar Resumos
  static void atualizarResumos(BuildContext context) async {
    // Abre tela de progresso
    Mensagem.aguardar(context: context, mensagem: 'Atualizando...');
    // Zera contadores
    int _resumoFamiliasAtivas = 0;
    List<ResumoEntregas> _resumoEntregas = [];
    // Firebase
    dev.log('Coletando dados...', name: 'ADMIN');
    var collection = FirebaseFirestore.instance.collection('familias');
    var snapFamilias = await collection.get();
    // Analisa cada familia
    dev.log('Analisando entradas...', name: 'ADMIN');
    for (var element in snapFamilias.docs) {
      dev.log('Família: ${element.id}', name: 'ADMIN');
      // Incrementa famílias ativas
      if (element.get('cadAtivo')) {
        _resumoFamiliasAtivas++;
      }
      // Analisa cada entrega
      var snapEntregas = await collection
          .doc(element.id)
          .collection('entregas')
          .withConverter<Entrega>(
            fromFirestore: (snapshots, _) =>
                Entrega.fromJson(snapshots.data()!),
            toFirestore: (documento, _) => documento.toJson(),
          )
          .get();
      for (var element in snapEntregas.docs) {
        var _ano = element.data().data.toDate().year;
        var _mes = element.data().data.toDate().month;
        dev.log('Entrega: ${element.id} ($_ano/$_mes)', name: 'ADMIN');
        // Busca entrega em ano e mes na lista
        var entrega = _resumoEntregas.singleWhere(
          (element) => element.ano == _ano && element.mes == _mes,
          orElse: () => ResumoEntregas(ano: _ano, mes: _mes, total: 0),
        );
        // Adiciona a lista na primeira vez
        if (entrega.total == 0) {
          _resumoEntregas.add(entrega);
        }
        // Incrementa total de entregas
        entrega.total++;
        dev.log('..entrega de ($_ano/$_mes) atualizada!', name: 'ADMIN');
      }
    }
    // Grava dados no banco
    dev.log('Gravando indices...', name: 'ADMIN');
    Resumo _resumo = Resumo(
      resumoEntregas: _resumoEntregas,
      resumoFamiliasAtivas: _resumoFamiliasAtivas,
    );
    await FirebaseFirestore.instance
        .collection(Resumo.colecao)
        .doc('geral')
        .withConverter<Resumo>(
          fromFirestore: (snapshots, _) => Resumo.fromJson(snapshots.data()!),
          toFirestore: (documento, _) => documento.toJson(),
        )
        .set(_resumo);
    dev.log('Atualização de indices finalizada!', name: 'ADMIN');
    // Fecha tela de progresso
    Modular.to.pop();
  }

  /// Resume a família pelo seus integrantes (crianças, adultos e idosos)
  static String resumirFamilia(Familia familia) {
    int criancas = 0;
    int adultos = 0;
    int idosos = 0;
    for (var element in familia.moradores) {
      int idade =
          getIdade(element.nascimento ?? Timestamp.fromDate(DateTime(1800)));
      if (idade == -1) {
        adultos += 1;
      } else if (idade < 15) {
        criancas += 1;
      } else if (idade < 60) {
        adultos += 1;
      } else {
        idosos += 1;
      }
    }
    if (criancas == 0 && adultos == 0 && idosos == 0) {
      return 'sem moradores cadastrados';
    }
    if (criancas != 0 && adultos == 0 && idosos == 0) {
      return '$criancas criança${Util.isPlural(criancas)}';
    }
    if (criancas != 0 && adultos != 0 && idosos == 0) {
      return '$criancas criança${Util.isPlural(criancas)} e $adultos adulto${Util.isPlural(adultos)}';
    }
    if (criancas != 0 && adultos == 0 && idosos != 0) {
      return '$criancas criança${Util.isPlural(criancas)} e $idosos idoso${Util.isPlural(idosos)}';
    }
    if (criancas != 0 && adultos != 0 && idosos != 0) {
      return '$criancas criança${Util.isPlural(criancas)}, $adultos adulto${Util.isPlural(adultos)} e $idosos idoso${Util.isPlural(idosos)}';
    }
    if (criancas == 0 && adultos != 0 && idosos == 0) {
      return '$adultos adulto${Util.isPlural(adultos)}';
    }
    if (criancas == 0 && adultos != 0 && idosos != 0) {
      return '$adultos adulto${Util.isPlural(adultos)} e $idosos idoso${Util.isPlural(idosos)}';
    }
    if (criancas == 0 && adultos == 0 && idosos != 0) {
      return '$idosos idoso${Util.isPlural(idosos)}';
    }
    return 'Analisar moradores cadastrados!';
  }
}
