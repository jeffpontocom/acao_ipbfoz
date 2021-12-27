import 'dart:developer' as dev;

import 'package:acao_ipbfoz/data/funcoes.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/date_symbol_data_local.dart';

import '/app_data.dart';
import '/models/entrega.dart';
import '/models/familia.dart';
import '/models/resumo.dart';
import '/utils/customs.dart';
import '/utils/estilos.dart';
import '/utils/util.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  /* VARIAVEIS */
  late double _appBarHeight;
  final _totalFamilias = ValueNotifier<int>(0);
  final _atualizarGrafico = ValueNotifier(false);
  late int _anoGrafico;
  late Resumo _indices;
  List<ResumoEntregas> _resumoEntregas = [];

  /* WIDGETS */

  /// Botão Administrar
  Widget get _btnAdmin {
    return IconButton(
      color: Colors.teal,
      icon: const Icon(Icons.admin_panel_settings_rounded),
      onPressed: () => Modular.to.pushNamed('/admin'),
    );
  }

  /// Botão Relatórios
  Widget get _btnRelatorios {
    return const IconButton(
      color: Colors.teal,
      icon: Icon(Icons.insert_chart_rounded),
      onPressed: null,
    );
  }

  /// Botão Novo Cadastro
  Widget get _btnNovoCadastro {
    return TextButton.icon(
      icon: const Icon(Icons.add_business_sharp),
      label: const Text(
        'Novo cadastro',
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
      onPressed: () {
        Funcao.novoCadastro(context);
      },
    );
  }

  /// Cabeçalhos
  SliverPersistentHeader _cabecalho(Widget titulo, Color cor) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: MySliverHeaderDelegate(
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

  /// Cria uma serie para gráficos com dados das entregas mensais
  List<charts.Series<ResumoEntregas, String>> _graficoEntregasMensais() {
    dev.log('Gerando gráfico', name: 'HOME');
    List<ResumoEntregas> _data = [];
    for (int i = 1; i <= 12; i++) {
      var _resumo = _resumoEntregas.singleWhere(
          (element) => element.ano == _anoGrafico && element.mes == i,
          orElse: () => ResumoEntregas(ano: _anoGrafico, mes: i, total: 0));
      _data.add(_resumo);
    }
    return [
      charts.Series<ResumoEntregas, String>(
        id: 'Entregas',
        colorFn: (_, __) => charts.MaterialPalette.teal.shadeDefault,
        data: _data,
        // Eixo X
        domainFn: (ResumoEntregas entrega, _) =>
            Util.listaMesCurto[entrega.mes],
        // Valores
        measureFn: (ResumoEntregas entrega, _) => entrega.total,
        // Labels
        labelAccessorFn: (ResumoEntregas entrega, _) =>
            entrega.total > 0 ? '${entrega.total}' : '',
      )
    ];
  }

  /// Listener para contagem de famílias e entregas
  void _escutarTotais() {
    FirebaseFirestore.instance
        .collection(Resumo.colecao)
        .doc('geral')
        .withConverter<Resumo>(
          fromFirestore: (snapshots, _) => Resumo.fromJson(snapshots.data()!),
          toFirestore: (documento, _) => documento.toJson(),
        )
        .snapshots()
        .listen(
      (document) {
        if (document.exists) {
          _atualizarGrafico.value = false;
          _indices = document.data() ??
              Resumo(resumoFamiliasAtivas: 0, resumoEntregas: []);
          _totalFamilias.value = _indices.resumoFamiliasAtivas ?? 0;
          _resumoEntregas = _indices.resumoEntregas ?? [];
          _atualizarGrafico.value = true;
          dev.log('Resumo de dados atualizado!', name: 'HOME');
        }
      },
      onDone: () {},
    );
  }

  /// Atualiza interface ao voltar para essa pagina
  /* FutureOr onGoBack(dynamic value) {
    _atualizarGrafico.value = false;
    setState(() {});
  } */

  /* METODOS DO SISTEMA */
  @override
  void initState() {
    initializeDateFormatting('pt_BR', null);
    _anoGrafico = Timestamp.now().toDate().year;
    _escutarTotais();
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
    _atualizarGrafico.dispose();
    _totalFamilias.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        //controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // AppBar
          SliverAppBar(
            // Definições
            expandedHeight: _appBarHeight,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
            // Stretch
            stretch: true,
            onStretchTrigger: () async {
              //_atualizarGrafico.value = true;
            },
            // Leading
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
                  Modular.to.pushNamed('/diacono?id=' + AppData.usuario!.uid);
                },
              ),
            ],
            // FlexibleSpace
            flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              bool isCollapsed = constraints.maxHeight <=
                  kToolbarHeight + MediaQuery.of(context).padding.top;

              return FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.blurBackground,
                  StretchMode.zoomBackground,
                ],
                // Titulo
                titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
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
                      strutStyle: const StrutStyle(
                          forceStrutHeight: true, height: 0.75),
                    ),
                    Visibility(
                      visible: !isCollapsed,
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
                          visible: !isCollapsed,
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
                                  image: AssetImage(
                                      'assets/icons/ic_launcher.png'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
          // Resumo
          _cabecalho(
            ValueListenableBuilder(
              valueListenable: _totalFamilias,
              builder: (BuildContext context, int value, Widget? child) {
                return Text(
                  '$value cadastros ativos',
                  textAlign: TextAlign.center,
                  style: Estilos.titulo.copyWith(fontSize: 14),
                );
              },
            ),
            Colors.grey.shade200,
          ),
          // Gráfico
          SliverToBoxAdapter(
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: Util.paddingListH(context)),
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  // Box do gráfico
                  SizedBox(
                    height: 150,
                    child: ValueListenableBuilder(
                      valueListenable: _atualizarGrafico,
                      child: const Center(child: CircularProgressIndicator()),
                      builder:
                          (BuildContext context, bool value, Widget? child) {
                        if (value) {
                          return charts.BarChart(
                            _graficoEntregasMensais(),
                            barRendererDecorator:
                                charts.BarLabelDecorator<String>(),
                            domainAxis: const charts.OrdinalAxisSpec(),
                            behaviors: [
                              charts.ChartTitle('Entregas',
                                  behaviorPosition:
                                      charts.BehaviorPosition.start),
                            ],
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                  // Box para seleção do ano
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.navigate_before),
                        onPressed: () {
                          setState(() {
                            _anoGrafico--;
                          });
                          //_atualizarGrafico.value = true;
                        },
                      ),
                      Text('$_anoGrafico'),
                      IconButton(
                        icon: const Icon(Icons.navigate_next),
                        onPressed: () {
                          setState(() {
                            _anoGrafico++;
                          });
                          //_atualizarGrafico.value = true;
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Lista Famílias
          _cabecalho(
            Text(
              'FAMÍLIAS',
              textAlign: TextAlign.center,
              style: Estilos.titulo,
            ),
            Colors.grey.shade200,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              StreamBuilder<QuerySnapshot<Familia>>(
                stream: FirebaseFirestore.instance
                    .collection('familias')
                    .where('cadAtivo', isEqualTo: true)
                    .orderBy('cadNomeFamilia')
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
                  // Lista
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true, // Obrigatorio (gera erro se falso)
                    physics: const NeverScrollableScrollPhysics(),
                    //physics:
                    //    const ScrollPhysics(), // Obrigatorio (nao move se nulo)
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
                          familia.cadNomeFamilia,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // Bairro
                        subtitle: Text(Funcao.resumirFamilia(familia) +
                            '\n' +
                            (familia.endBairro ?? '[sem bairro]')),
                        //+ ' • ' +
                        //familia.cadEntregas.toString() +
                        //' entregas realizadas.'),
                        onTap: () {
                          Modular.to.pushNamed('/familia?id=' +
                              snapshots.data!.docs[index].reference.id);
                        },
                      );
                    },
                  );
                },
              ),
            ]),
          ),
        ],
      ),
      persistentFooterButtons: [_btnAdmin, _btnRelatorios, _btnNovoCadastro],
    );
  }
}
