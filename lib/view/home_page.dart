import 'dart:developer' as dev;
import 'dart:async';

import 'package:acao_ipbfoz/data/funcoes.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/date_symbol_data_local.dart';

import '/app_data.dart';
import '/main.dart';
import '/models/entrega.dart';
import '/models/familia.dart';
import '../models/resumo.dart';
import '/models/morador.dart';
import '/utils/customs.dart';
import '/utils/estilos.dart';
import '/utils/mensagens.dart';
import '/utils/util.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  /* VARIAVEIS */
  late Resumo _indices;
  final _totalFamilias = ValueNotifier<int>(0);
  final _atualizarGrafico = ValueNotifier(false);
  late int _anoGrafico;
  List<ResumoEntregas> _resumoEntregas = [];
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
    TextEditingController ctrNomeBeneficiado = TextEditingController();
    //TextEditingController ctrSolicitante = TextEditingController();
    bool ctrEspecial = false;

    return TextButton.icon(
      icon: const Icon(Icons.add_business_sharp),
      label: const Text(
        'Novo cadastro',
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
      onPressed: () {
        // Widget
        Widget conteudo = Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: ctrNomeBeneficiado,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                decoration: Estilos.mInputDecoration
                    .copyWith(labelText: 'Nome do beneficiado'),
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
                    //contentPadding: const EdgeInsets.all(0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    tileColor: Colors.amber.shade100,
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
                  // Cria nova familia
                  var novaFamilia = Familia(
                      cadAtivo: true,
                      cadDiacono: auth.currentUser!.uid,
                      cadData: Timestamp.now(),
                      cadNomeFamilia: ctrNomeBeneficiado.text,
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
                      // Abre tela da familia
                      Modular.to
                          .popAndPushNamed('/familia?id=${value.id}',
                              arguments: true)
                          .then(onGoBack);
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
          conteudo: Scrollbar(
            isAlwaysShown: true,
            showTrackOnHover: true,
            controller: scroll,
            child: SingleChildScrollView(
              child: conteudo,
              controller: scroll,
            ),
          ),
        );
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
        // Eixo Y
        measureFn: (ResumoEntregas entrega, _) => entrega.total,
        // Label
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
      (event) {
        if (event.exists) {
          _atualizarGrafico.value = false;
          _indices = event.data() ??
              Resumo(resumoFamiliasAtivas: 0, resumoEntregas: []);
          _totalFamilias.value = _indices.resumoFamiliasAtivas ?? 0;
          _resumoEntregas = _indices.resumoEntregas ?? [];
          _atualizarGrafico.value = true;
          dev.log('Resumo de dados atualizado!', name: 'HOME');
        }
      },
    );
  }

  /// Atualiza interface ao voltar para essa pagina
  FutureOr onGoBack(dynamic value) {
    _atualizarGrafico.value = false;
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
    _anoGrafico = Timestamp.now().toDate().year;
    _escutarTotais();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_isAppBarExpanded != _sliverCollapsed) {
          setState(() {
            _sliverCollapsed = _isAppBarExpanded;
          });
        }
      });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _appBarHeight = MediaQuery.of(context).size.height / 4;
    _atualizarGrafico.value = false;
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
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: Util.paddingListH(context)),
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  SizedBox(
                    height: 150,
                    child: ValueListenableBuilder(
                      valueListenable: _atualizarGrafico,
                      builder:
                          (BuildContext context, bool value, Widget? child) {
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
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.navigate_before),
                        onPressed: () {
                          _atualizarGrafico.value = false;
                          setState(() {
                            _anoGrafico--;
                          });
                        },
                      ),
                      Text('$_anoGrafico'),
                      IconButton(
                        icon: const Icon(Icons.navigate_next),
                        onPressed: () {
                          _atualizarGrafico.value = false;
                          setState(() {
                            _anoGrafico++;
                          });
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
            delegate: SliverChildListDelegate(
              [
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
