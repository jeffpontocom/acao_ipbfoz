import 'dart:async';

import 'package:acao_ipbfoz/models/entrega.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../app_data.dart';
import '../models/familia.dart';
import '../models/morador.dart';
import '../ui/estilos.dart';
import '../utils/util.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /* VARIAVEIS */
  var _totalFamilias = new ValueNotifier<int>(0);
  var _totalEntregas = new ValueNotifier<int>(0);

  /* WIDGETS */

  /// Botão Administrar
  Widget get _btnAdmin {
    return IconButton(
      onPressed: null,
      icon: const Icon(Icons.admin_panel_settings_rounded),
    );
  }

  /// Botão Relatórios
  Widget get _btnRelatorios {
    return IconButton(
      onPressed: null,
      icon: const Icon(Icons.insert_chart_rounded),
    );
  }

  /// Botão Novo Cadastro
  Widget get _btnNovoCadastro {
    return TextButton.icon(
      icon: const Hero(
        tag: 'novo',
        child: Icon(Icons.add_business_sharp),
      ),
      label: Text(
        'Novo cadastro',
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
      onPressed: _novoCadastro,
    );
  }

  /* METODOS */
  ValueNotifier<bool> tudoContado = ValueNotifier(false);

  /// Conta o total de famílias cadastradas e o total global de entregas
  /// realizadas
  void _contarTotais(QuerySnapshot<Familia>? data) {
    _totalFamilias.value = data!.size;
    _totalEntregas.value = 0;
    //mEntregas.clear();
    int elementos = 0;
    data.docs.forEach((element) {
      // Atualiza o total de entregas pelo valor pre-carregado
      _totalEntregas.value += element.data().cadEntregas;
      // Atualizar o total de entregas verificando cada item da coleção
      element.reference
          .collection('entregas')
          .withConverter<Entrega>(
            fromFirestore: (snapshots, _) =>
                Entrega.fromJson(snapshots.data()!),
            toFirestore: (documento, _) => documento.toJson(),
          )
          .get()
          .then((entregas) {
        elementos++;
        if (entregas.size > 0) {
          // Atualiza o total de entregas
          element.reference.update({'cadEntregas': entregas.size});
          // Preenche o grafico
          entregas.docs.forEach((element) {
            mEntregas[element.data().data.toDate().month - 1].add(1);
          });
        } else {
          // Atualizar o total de entregas
          element.reference.update({'cadEntregas': 0});
        }
        if (elementos == _totalFamilias.value) {
          tudoContado.value = true;
        }
      });
    });
    print('Totais contabilizados e atualizados!');
  }

  /// Conta o total de integrantes de uma familia
  String _contarIntegrantes(Familia familia) {
    int criancas = 0;
    int adultos = 0;
    int idosos = 0;
    familia.moradores.forEach((element) {
      int idade = getIdade(element.nascimento);
      if (idade == -1)
        adultos += 1;
      else if (idade < 15)
        criancas += 1;
      else if (idade < 60)
        adultos += 1;
      else
        idosos += 1;
    });
    if (criancas == 0 && adultos == 0 && idosos == 0)
      return 'sem moradores cadastrados';
    if (criancas != 0 && adultos == 0 && idosos == 0)
      return '$criancas criança${_ePlural(criancas)}';
    if (criancas != 0 && adultos != 0 && idosos == 0)
      return '$criancas criança${_ePlural(criancas)} e $adultos adulto${_ePlural(adultos)}';
    if (criancas != 0 && adultos == 0 && idosos != 0)
      return '$criancas criança${_ePlural(criancas)} e $idosos idoso${_ePlural(idosos)}';
    if (criancas != 0 && adultos != 0 && idosos != 0)
      return '$criancas criança${_ePlural(criancas)}, $adultos adulto${_ePlural(adultos)} e $idosos idoso${_ePlural(idosos)}';
    if (criancas == 0 && adultos != 0 && idosos == 0)
      return '$adultos adulto${_ePlural(adultos)}';
    if (criancas == 0 && adultos != 0 && idosos != 0)
      return '$adultos adulto${_ePlural(adultos)} e $idosos idoso${_ePlural(idosos)}';
    if (criancas == 0 && adultos == 0 && idosos != 0)
      return '$idosos idoso${_ePlural(idosos)}';
    return 'analisar moradores cadastrados';
  }

  String _ePlural(int qtd) {
    return qtd > 1 ? 's' : '';
  }

  /// Abre a tela para um novo cadastro
  _novoCadastro() {
    Modular.to.pushNamed('/familia').then(onGoBack);
  }

  /// Atualiza interface ao voltar para essa pagina
  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  /* METODOS DO SISTEMA */
  @override
  void initState() {
    initializeDateFormatting('pt_BR', null);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        //floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              // Definições
              expandedHeight: 200,
              pinned: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              // Leading
              leading: innerBoxIsScrolled
                  ? IconButton(
                      icon: Image.asset('assets/icons/ic_launcher.png'),
                      onPressed: null,
                    )
                  : null,
              leadingWidth: 48,
              // Actions
              actions: [
                TextButton.icon(
                  icon: Icon(Icons.account_circle_rounded),
                  label: Text(AppData.usuario?.nome.split(' ')[0] ?? 'Logar'),
                  onPressed: () {
                    Modular.to
                        .pushNamed('/diacono?id=' + AppData.usuario!.uid)
                        .then(onGoBack);
                  },
                ),
              ],
              // FlexibleSpace
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: [
                  StretchMode.blurBackground,
                  StretchMode.zoomBackground
                ],
                // Titulo
                titlePadding: EdgeInsets.only(left: 48, bottom: 16),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      AppData.appName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pacifico',
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      strutStyle:
                          StrutStyle(forceStrutHeight: true, height: 0.75),
                    ),
                    Visibility(
                      visible: !innerBoxIsScrolled,
                      child: Text(
                        'Igreja Presbiteriana de Foz do Iguaçu',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
                // Fundo
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/home-background.jpg'),
                    ),
                    Row(
                      children: [
                        SizedBox(width: 24),
                        SizedBox(
                          width: 96,
                          height: 96,
                          child: Hero(
                            tag: 'logo',
                            child: Transform.rotate(
                              angle: 5.75,
                              child: Image(
                                alignment: Alignment.topLeft,
                                fit: BoxFit.scaleDown,
                                image:
                                    AssetImage('assets/icons/ic_launcher.png'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.grey.shade200,
                padding: EdgeInsets.all(12),
                child: ValueListenableBuilder(
                  valueListenable: _totalFamilias,
                  builder: (BuildContext context, int value, Widget? child) {
                    return Text(
                      '$value famílias sendo atendidas atualmente',
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            )
          ];
        },
        body: Scrollbar(
          isAlwaysShown: true,
          showTrackOnHover: true,
          controller: _scrollController,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Grafico
                Container(
                  height: 150,
                  color: Colors.grey.shade100,
                  child: ValueListenableBuilder(
                    valueListenable: tudoContado,
                    builder: (BuildContext context, bool value, Widget? child) {
                      return charts.BarChart(
                        _analisarEntregas(),
                        barRendererDecorator:
                            charts.BarLabelDecorator<String>(),
                        domainAxis: charts.OrdinalAxisSpec(),
                        behaviors: [
                          charts.ChartTitle('Entregas',
                              behaviorPosition: charts.BehaviorPosition.start),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 12.0),
                // Lista
                Text(
                  'FAMÍLIAS',
                  textAlign: TextAlign.center,
                  style: Estilos.titulo,
                ),
                StreamBuilder<QuerySnapshot<Familia>>(
                  stream: FirebaseFirestore.instance
                      .collection('familias')
                      .where('cadAtivo', isEqualTo: true)
                      .withConverter<Familia>(
                        fromFirestore: (snapshots, _) =>
                            Familia.fromJson(snapshots.data()!),
                        toFirestore: (documento, _) => documento.toJson(),
                      )
                      .snapshots(),
                  builder: (context, snapshots) {
                    if (snapshots.hasError) {
                      return Center(
                        heightFactor: 5,
                        child: Text(snapshots.error.toString()),
                      );
                    }
                    if (!snapshots.hasData) {
                      return const Center(
                          heightFactor: 5, child: CircularProgressIndicator());
                    }
                    if (snapshots.data!.size == 0) {
                      return Center(
                        heightFactor: 5,
                        child: Text('Nenhum cadastro localizado!'),
                      );
                    }
                    final data = snapshots.data;
                    // Realizar contagens
                    if (snapshots.connectionState == ConnectionState.active) {
                      if (data!.size != _totalFamilias.value) {
                        WidgetsBinding.instance
                            ?.addPostFrameCallback((_) => _contarTotais(data));
                      }
                    }
                    // Widget
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true, // Obrigatorio (gera erro se falso)
                      physics:
                          ScrollPhysics(), // Obrigatorio (nao move se nulo)
                      padding: EdgeInsets.symmetric(
                        horizontal: Util.paddingListH(context),
                      ),
                      itemCount: data!.size,
                      itemBuilder: (context, index) {
                        Familia familia = data.docs[index].data();
                        // Lista
                        return ListTile(
                          horizontalTitleGap: 2,
                          visualDensity: VisualDensity.compact,
                          isThreeLine: true,
                          leading: Icon(Icons.family_restroom_rounded),
                          // Nome do morador
                          title: Text(
                            familia.moradores[familia.famResponsavel].nome,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // Bairro
                          subtitle: Text(_contarIntegrantes(familia) +
                              '\n' +
                              familia.endBairro +
                              ' • ' +
                              familia.cadEntregas.toString() +
                              ' entregas realizadas.'),
                          onTap: () {
                            Modular.to
                                .pushNamed('/familia?id=' +
                                    data.docs[index].reference.id)
                                .then(onGoBack);
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      persistentFooterButtons: [_btnAdmin, _btnRelatorios, _btnNovoCadastro],
    );
  }

  static List<Entregas> mEntregas = [
    new Entregas(0, 0),
    new Entregas(1, 0),
    new Entregas(2, 0),
    new Entregas(3, 0),
    new Entregas(4, 0),
    new Entregas(5, 0),
    new Entregas(6, 0),
    new Entregas(7, 0),
    new Entregas(8, 0),
    new Entregas(9, 0),
    new Entregas(10, 0),
    new Entregas(11, 0),
  ];

  /// Create one series with sample hard coded data.
  static List<charts.Series<Entregas, String>> _analisarEntregas() {
    return [
      new charts.Series<Entregas, String>(
        id: 'Entregas',
        colorFn: (_, __) => charts.MaterialPalette.teal.shadeDefault,
        domainFn: (Entregas sales, _) => months[sales.mes],
        measureFn: (Entregas sales, a) => sales.total,
        data: mEntregas,
        labelAccessorFn: (Entregas sales, a) =>
            sales.total > 0 ? '${sales.total}' : '',
      )
    ];
  }
}

/// Sample ordinal data type.
class Entregas {
  final int mes;
  int total = 0;

  Entregas(this.mes, this.total);

  void add(int valor) {
    total += valor;
  }
}

List<String> months = [
  'Jan',
  'Fev',
  'Mar',
  'Abr',
  'Maio',
  'Jun',
  'Jul',
  'Ago',
  'Set',
  'Out',
  'Nov',
  'Dez'
];
