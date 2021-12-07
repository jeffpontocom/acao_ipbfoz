import 'dart:developer' as dev;
import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/date_symbol_data_local.dart';

import '/app_data.dart';
import '/models/entrega.dart';
import '/models/familia.dart';
import '/models/morador.dart';
import '/ui/estilos.dart';
import '/utils/util.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /* VARIAVEIS */
  final _totalFamilias = ValueNotifier<int>(0);
  final _totalEntregas = ValueNotifier<int>(0);
  final _contagemConcluida = ValueNotifier(false);
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

  final ScrollController _scrollController = ScrollController();

  /* WIDGETS */

  /// Botão Administrar
  Widget get _btnAdmin {
    return IconButton(
      icon: const Icon(Icons.admin_panel_settings_rounded),
      onPressed: () => Modular.to.pushNamed('/admin').then(onGoBack),
    );
  }

  /// Botão Relatórios
  Widget get _btnRelatorios {
    return const IconButton(
      onPressed: null,
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

  /* METODOS */

  /// Conta o total de famílias cadastradas e o total global de entregas
  /// realizadas
  void _contarTotais(QuerySnapshot<Familia>? data) {
    // Total de famílias
    _totalFamilias.value = data!.size;
    // Zerando entregas
    _totalEntregas.value = 0;
    _contagemConcluida.value = false;
    int analisadas = 0;
    // Analizando cada familia
    for (var element in data.docs) {
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
              //stretch: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              ),
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
                      strutStyle: const StrutStyle(
                          forceStrutHeight: true, height: 0.75),
                    ),
                    Visibility(
                      visible: !innerBoxIsScrolled,
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
                        SizedBox(
                          width: 72,
                          height: 112,
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Informação em destaque
            SliverToBoxAdapter(
              child: Container(
                color: Colors.grey.shade200,
                padding: const EdgeInsets.all(12),
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
        // Corpo
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
                const SizedBox(height: 12.0),
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
                      if ((snapshots.data?.size ?? _totalFamilias.value) !=
                          _totalFamilias.value) {
                        // Executar função apenas o após carregamento da interface
                        WidgetsBinding.instance?.addPostFrameCallback(
                            (_) => _contarTotais(snapshots.data));
                      }
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
        ),
      ),
      persistentFooterButtons: [_btnAdmin, _btnRelatorios, _btnNovoCadastro],
    );
  }
}

/// Sample ordinal data type.
class EntregaMensal {
  final int mes;
  int total = 0;

  EntregaMensal(this.mes, this.total);

  void increment() => total++;
}
