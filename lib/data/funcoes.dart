import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../main.dart';
import '/models/entrega.dart';
import '/models/familia.dart';
import '/models/morador.dart';
import '/models/resumo.dart';
import '/utils/estilos.dart';
import '/utils/mensagens.dart';
import '/utils/util.dart';

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
      Familia familia = Familia.fromJson(element.data());
      dev.log('Família: ${element.id}', name: 'ADMIN');
      // Incrementa famílias ativas
      //if (element.get('cadAtivo')) {
      if (familia.cadAtivo) {
        _resumoFamiliasAtivas++;
      }
      // Verifica se familiar Responsavel está preenchido (cadastro da versão <= 1.1.0)
      var nomeFamilia = await element.data().update(
          'cadNomeFamilia', (value) => value,
          ifAbsent: () => familia.moradores[familia.famResponsavel ?? 0].nome);
      await element.reference.update({'cadNomeFamilia': nomeFamilia});
      dev.log(nomeFamilia, name: 'ADMIN');
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
      return '$adultos adulto${Util.isPlural(adultos)} e $criancas criança${Util.isPlural(criancas)}';
    }
    if (criancas != 0 && adultos == 0 && idosos != 0) {
      return '$idosos idoso${Util.isPlural(idosos)} e $criancas criança${Util.isPlural(criancas)}';
    }
    if (criancas != 0 && adultos != 0 && idosos != 0) {
      return '$adultos adulto${Util.isPlural(adultos)}, $idosos idoso${Util.isPlural(idosos)} e $criancas criança${Util.isPlural(criancas)}';
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

  /// Criar novo cadastro
  static void novoCadastro(BuildContext context) {
    TextEditingController ctrNomeBeneficiado = TextEditingController();
    TextEditingController ctrBairro = TextEditingController();
    bool ctrEspecial = false;

    // Widget
    Widget conteudo = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nome do Beneficiario
          TextFormField(
            controller: ctrNomeBeneficiado,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            decoration: Estilos.mInputDecoration
                .copyWith(labelText: 'Nome do beneficiado'),
          ),
          const SizedBox(height: 16),
          // Bairro
          TextFormField(
            controller: ctrBairro,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.next,
            decoration: Estilos.mInputDecoration.copyWith(labelText: 'Bairro'),
          ),
          const SizedBox(height: 16),
          // E Especial
          StatefulBuilder(
            builder: (context, setState) {
              return CheckboxListTile(
                tristate: false,
                title: const Text("PNE"),
                visualDensity: VisualDensity.compact,
                subtitle: const Text("Portador de Necessidades Especiais"),
                secondary: const Icon(Icons.accessible),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                tileColor: Colors.grey.shade200,
                selectedTileColor: Colors.amber,
                selected: ctrEspecial,
                value: ctrEspecial,
                onChanged: (value) {
                  setState(() {
                    ctrEspecial = value ?? false;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Abre tela de progresso
              Mensagem.aguardar(
                  context: context, mensagem: 'Criando registro...');
              // Cria nova familia
              var novaFamilia = Familia(
                  cadAtivo: true,
                  cadDiacono: auth.currentUser!.uid,
                  cadData: Timestamp.now(),
                  cadNomeFamilia: ctrNomeBeneficiado.text,
                  endBairro: ctrBairro.text,
                  moradores: [
                    Morador(
                      nome: ctrNomeBeneficiado.text,
                      especial: ctrEspecial,
                    ),
                  ]);
              // Registra no Firebase
              FirebaseFirestore.instance
                  .collection('familias')
                  .add(novaFamilia.toJson())
                  .then(
                (value) {
                  // Modifica Resumo
                  FirebaseFirestore.instance
                      .collection(Resumo.colecao)
                      .doc('geral')
                      .update(
                          {'resumoFamiliasAtivas': FieldValue.increment(1)});
                  // Fecha tela de progresso
                  Modular.to.pop();
                  // Fecha bottom dialog e abre tela da familia
                  Modular.to.popAndPushNamed('/familia?id=${value.id}',
                      arguments: true);
                },
              );
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
    // Bottom dialog
    var scroll = ScrollController();
    Mensagem.bottomDialog(
      context: context,
      icon: Icons.add_business_sharp,
      titulo: 'Novo cadastro',
      conteudo: SingleChildScrollView(
        controller: scroll,
        child: conteudo,
      ),
    );
  }
}
