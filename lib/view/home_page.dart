import 'dart:developer' as dev;
import 'dart:async';
import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/date_symbol_data_local.dart';

import '/app_data.dart';
import '/models/entrega.dart';
import '/models/familia.dart';
import '/models/morador.dart';
import '../utils/estilos.dart';
import '/utils/util.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  /* VARIAVEIS */
  final _totalFamilias = ValueNotifier<int>(0);
  final _totalEntregas = ValueNotifier<int>(0);
  final _contagemConcluida = ValueNotifier(false);
  late int anoGrafico;
  final List<EntregaMensal> _entregasMensais = [
    EntregaMensal(0, 0),
    EntregaMensal(1, 0),
    EntregaMensal(2, 0),
    EntregaMensal(3, 0),
    EntregaMensal(4, 0),
    EntregaMensal(5, 0),
    EntregaMensal(6, 0),
    EntregaMensal(7, 0),
    EntregaMensal(8, 0),
    EntregaMensal(9, 0),
    EntregaMensal(10, 0),
    EntregaMensal(11, 0),
  ];

  late double _appBarHeight;
  late final ScrollController _scrollController;
  bool _sliverCollapsed = false;

  /* WIDGETS */

  /// Botão Administrar
  Widget get _btnAdmin {
    return IconButton(
      icon: const Icon(Icons.admin_panel_settings_rounded),
      color: Colors.teal,
      onPressed: () => Modular.to.pushNamed('/admin').then(onGoBack),
    );
  }

  /// Botão Relatórios
  Widget get _btnRelatorios {
    return const IconButton(
      onPressed: null,
      color: Colors.teal,
      icon: Icon(Icons.insert_chart_rounded),
    );
  }

  /// Botão Novo Cadastro
  Widget get _btnNovoCadastro {
    return TextButton.icon(
      icon: const Hero(
        tag: 'novo',
        child: Icon(Icons.add_business_sharp),
      ),
      label: const Text(
        'Novo cadastro',
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
      onPressed: () => Modular.to.pushNamed('/familia').then(onGoBack),
    );
  }

  /// Cabeçalhos
  SliverPersistentHeader _cabecalho(Widget titulo, Color cor) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverHeaderDelegate(
        minHeight: 40,
        maxHeight: 56,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4),
          color: cor,
          child: titulo,
        ),
      ),
    );
  }

  /* METODOS */

  /// Conta o total de famílias cadastradas e o total global de entregas
  /// realizadas
  void _contarTotais(QuerySnapshot<Familia>? data) {
    // Se contagem ainda não concluida e total de entregas diferente de zero
    // Significa que contagem está em andamento
    if (_contagemConcluida.value) {
      return;
    }
    // Total de famílias
    _totalFamilias.value = data!.size;
    // Zerando entregas
    _totalEntregas.value = 0;
    for (var element in _entregasMensais) {
      element.clear();
    }
    _contagemConcluida.value = false;
    int analisadas = 0;
    // Analizando cada familia
    for (var element in data.docs) {
      // Atualiza o total de entregas pelo valor pre-carregado
      _totalEntregas.value += element.data().cadEntregas;
      // Atualizar o total de entregas verificando cada item da coleção
      element.reference
          .collection('entregas')
          .where('data',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime(anoGrafico, 1, 1)))
          .where('data',
              isLessThanOrEqualTo:
                  Timestamp.fromDate(DateTime(anoGrafico, 12, 31)))
          .withConverter<Entrega>(
            fromFirestore: (snapshots, _) =>
                Entrega.fromJson(snapshots.data()!),
            toFirestore: (documento, _) => documento.toJson(),
          )
          .get()
          .then((entregas) {
        // Registra a analise
        analisadas++;
        if (entregas.size > 0) {
          // Atualiza o total de entregas
          element.reference.update({'cadEntregas': entregas.size});
          // Preenche a variavel do gráfico
          for (var element in entregas.docs) {
            _entregasMensais[element.data().data.toDate().month - 1]
                .increment();
          }
        } else {
          // Atualizar o total de entregas
          element.reference.update({'cadEntregas': 0});
        }
        // Finaliza no último elemento
        if (analisadas == _totalFamilias.value) {
          _contagemConcluida.value = true;
        }
      });
    }
    dev.log('Totais contabilizados e atualizados!', name: 'HOME');
  }

  /// Conta o total de integrantes de uma familia
  String _contarIntegrantes(Familia familia) {
    int criancas = 0;
    int adultos = 0;
    int idosos = 0;
    for (var element in familia.moradores) {
      int idade = getIdade(element.nascimento);
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

  /// Cria uma serie para gráficos com dados das entregas mensais
  List<charts.Series<EntregaMensal, String>> _graficoEntregasMensais() {
    return [
      charts.Series<EntregaMensal, String>(
        id: 'Entregas',
        colorFn: (_, __) => charts.MaterialPalette.teal.shadeDefault,
        domainFn: (EntregaMensal sales, _) => Util.listaMesCurto[sales.mes],
        measureFn: (EntregaMensal sales, a) => sales.total,
        data: _entregasMensais,
        labelAccessorFn: (EntregaMensal sales, a) =>
            sales.total > 0 ? '${sales.total}' : '',
      )
    ];
  }

  /// Atualiza interface ao voltar para essa pagina
  FutureOr onGoBack(dynamic value) {
    _contagemConcluida.value = false;
    setState(() {});
  }

  /// Verifica se a AppBar está expandida
  bool get _isAppBarExpanded {
    return _scrollController.hasClients &&
        _scrollController.offset > (_appBarHeight - kToolbarHeight);
  }

  /* METODOS DO SISTEMA */
  @override
  void initState() {
    initializeDateFormatting('pt_BR', null);
    _scrollController = ScrollController()
      ..addListener(() {
        if (_isAppBarExpanded != _sliverCollapsed) {
          setState(() {
            _sliverCollapsed = _isAppBarExpanded;
          });
        }
      });
    anoGrafico = Timestamp.now().toDate().year;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _appBarHeight = MediaQuery.of(context).size.height / 4;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // AppBar
          SliverAppBar(
            // Definições
            expandedHeight: _appBarHeight,
            pinned: true, floating: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
            // Leading
            leading: _sliverCollapsed
                ? IconButton(
                    icon: Image.asset('assets/icons/ic_launcher.png'),
                    onPressed: null,
                  )
                : null,
            leadingWidth: 48,
            // Actions
            actions: [
              TextButton.icon(
                icon: Hero(
                  tag: AppData.usuario?.uid ?? '',
                  child: const Icon(Icons.account_circle_rounded),
                ),
                label: Text(AppData.usuario?.nome?.split(' ')[0] ?? 'ERRO'),
                onPressed: () {
                  Modular.to
                      .pushNamed('/diacono?id=' + AppData.usuario!.uid)
                      .then(onGoBack);
                },
              ),
            ],
            // FlexibleSpace
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.blurBackground,
                StretchMode.zoomBackground
              ],
              // Titulo
              titlePadding: const EdgeInsets.only(left: 48, bottom: 16),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    AppData.appName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pacifico',
                    ),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    strutStyle:
                        const StrutStyle(forceStrutHeight: true, height: 0.75),
                  ),
                  Visibility(
                    visible: !_sliverCollapsed,
                    child: const Text(
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
                  // Imagem de fundo
                  const Image(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/home-background.jpg'),
                  ),
                  // Logotipo de fundo
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(width: 24), // espaço a esquerda
                      Visibility(
                        visible: !_sliverCollapsed,
                        child: SizedBox(
                          width: 72,
                          height: 120,
                          child: Hero(
                            tag: 'logo',
                            child: Transform.rotate(
                              angle: 5.9,
                              child: const Image(
                                alignment: Alignment.topLeft,
                                fit: BoxFit.scaleDown,
                                image:
                                    AssetImage('assets/icons/ic_launcher.png'),
                              ),
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
          // Resumo
          _cabecalho(
            ValueListenableBuilder(
              valueListenable: _totalFamilias,
              builder: (BuildContext context, int value, Widget? child) {
                return Text(
                  '$value famílias sendo atendidas atualmente',
                  textAlign: TextAlign.center,
                  style: Estilos.titulo.copyWith(fontSize: 14),
                );
              },
            ),
            Colors.grey.shade200,
          ),
          // Gráfico
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  height: 150,
                  color: Colors.grey.shade100,
                  child: ValueListenableBuilder(
                    valueListenable: _contagemConcluida,
                    builder: (BuildContext context, bool value, Widget? child) {
                      return charts.BarChart(
                        _graficoEntregasMensais(),
                        barRendererDecorator:
                            charts.BarLabelDecorator<String>(),
                        domainAxis: const charts.OrdinalAxisSpec(),
                        behaviors: [
                          charts.ChartTitle('Entregas',
                              behaviorPosition: charts.BehaviorPosition.start),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.navigate_before),
                      onPressed: () {
                        _contagemConcluida.value = false;
                        //_totalFamilias.value = 0; // zera para força recontagem
                        setState(() {
                          anoGrafico--;
                        });
                      },
                    ),
                    Text('$anoGrafico'),
                    IconButton(
                      icon: const Icon(Icons.navigate_next),
                      onPressed: () {
                        _contagemConcluida.value = false;
                        //_totalFamilias.value = 0; // zera para força recontagem
                        setState(() {
                          anoGrafico++;
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
          ), // Lista Famílias

          _cabecalho(
            Text(
              'FAMÍLIAS',
              textAlign: TextAlign.center,
              style: Estilos.titulo,
            ),
            Colors.grey.shade200,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                StreamBuilder<QuerySnapshot<Familia>>(
                  stream: FirebaseFirestore.instance
                      .collection('familias')
                      .where('cadAtivo', isEqualTo: true)
                      .orderBy('cadData')
                      .withConverter<Familia>(
                        fromFirestore: (snapshots, _) =>
                            Familia.fromJson(snapshots.data()!),
                        toFirestore: (documento, _) => documento.toJson(),
                      )
                      .snapshots(),
                  builder: (context, snapshots) {
                    // Tela de carregamento
                    if (!snapshots.hasData) {
                      return const Center(
                          heightFactor: 5, child: CircularProgressIndicator());
                    }
                    // Tela de erro
                    if (snapshots.hasError) {
                      return Center(
                        heightFactor: 5,
                        child: Text(snapshots.error.toString()),
                      );
                    }
                    // Tela de cadastros vazio
                    if (snapshots.data!.size == 0) {
                      return const Center(
                        heightFactor: 5,
                        child: Text('Nenhum cadastro localizado!'),
                      );
                    }
                    // Realizar contagens ao estabilizar conexão
                    if (snapshots.connectionState == ConnectionState.active) {
                      // Contar apenas se total de famílias for alterado
                      //if ((snapshots.data?.size ?? _totalFamilias.value) !=
                      //    _totalFamilias.value) {
                      // Executar função apenas o após carregamento da interface
                      WidgetsBinding.instance?.addPostFrameCallback(
                        (_) => _contarTotais(snapshots.data),
                      );
                      //}
                    }
                    // Widget
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true, // Obrigatorio (gera erro se falso)
                      physics:
                          const ScrollPhysics(), // Obrigatorio (nao move se nulo)
                      padding: EdgeInsets.symmetric(
                        horizontal: Util.paddingListH(context),
                      ),
                      itemCount: snapshots.data?.size ?? 0,
                      itemBuilder: (context, index) {
                        Familia familia = snapshots.data!.docs[index].data();
                        // Elementos
                        return ListTile(
                          horizontalTitleGap: 2,
                          visualDensity: VisualDensity.compact,
                          isThreeLine: true,
                          leading: const Icon(Icons.family_restroom_rounded),
                          // Nome do morador
                          title: Text(
                            familia.moradores[familia.famResponsavel].nome,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // Bairro
                          subtitle: Text(_contarIntegrantes(familia) +
                              '\n' +
                              familia.endBairro),
                          //+ ' • ' +
                          //familia.cadEntregas.toString() +
                          //' entregas realizadas.'),
                          onTap: () {
                            Modular.to
                                .pushNamed('/familia?id=' +
                                    snapshots.data!.docs[index].reference.id)
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
        ],
      ),
      persistentFooterButtons: [_btnAdmin, _btnRelatorios, _btnNovoCadastro],
    );
  }
}

/// Classe para registro do total de entregas mensais
class EntregaMensal {
  final int mes;
  int total = 0;

  EntregaMensal(this.mes, this.total);

  void increment() => total++;

  void clear() => total = 0;
}

/// Cabeçalhos Delegados
class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
