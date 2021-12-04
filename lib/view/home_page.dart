import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../app_data.dart';
import '../models/familia.dart';
import '../models/morador.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /* VARIAVEIS */
  var _totalFamilias = new ValueNotifier<int>(0);
  var _totalEntregas = new ValueNotifier<int>(0);

  /* WIDGETS */

  // Titulo com os dados do usuario
  Widget get _appBarTitulo {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Hero(
          tag: 'username',
          child: Text(
            _isShrink ? 'IPBFoz' : 'Igreja Presbiteriana de Foz do Iguaçu',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            strutStyle: StrutStyle(fontSize: 18, forceStrutHeight: true),
          ),
        ),
        Hero(
          tag: 'appname',
          child: Text(
            AppData.appName,
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              fontFamily: 'Pacifico',
            ),
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            strutStyle: StrutStyle(fontSize: 25, forceStrutHeight: true),
          ),
        ),
      ],
    );
  }

  // Botões Bottom AppBar
  Widget get _btnAdmin {
    return IconButton(
      onPressed: null,
      icon: const Icon(Icons.admin_panel_settings_rounded),
    );
  }

  Widget get _btnRelatorios {
    return IconButton(
      onPressed: null,
      icon: const Icon(Icons.insert_chart_rounded),
    );
  }

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

  /// Contadores
  void _contarTotais(QuerySnapshot<Familia>? data) {
    _totalFamilias.value = data!.size;
    _totalEntregas.value = 0;
    data.docs.forEach((element) {
      _totalEntregas.value += element.data().cadEntregas;
      element.reference.collection('entregas').get().then((value) {
        if (value.size > 0) {
          element.reference.update({'cadEntregas': value.size});
        } else {
          element.reference.update({'cadEntregas': 0});
        }
      });
    });
    print('Totais contabilizados e atualizados!');
  }

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
      return '$criancas crianças';
    if (criancas != 0 && adultos != 0 && idosos == 0)
      return '$criancas crianças e $adultos adultos';
    if (criancas != 0 && adultos == 0 && idosos != 0)
      return '$criancas crianças e $idosos idosos';
    if (criancas != 0 && adultos != 0 && idosos != 0)
      return '$criancas crianças, $adultos adultos e $idosos idosos';
    if (criancas == 0 && adultos != 0 && idosos == 0) return '$adultos adultos';
    if (criancas == 0 && adultos != 0 && idosos != 0)
      return '$adultos adultos e $idosos idosos';
    if (criancas == 0 && adultos == 0 && idosos != 0) return '$idosos idosos';
    return 'analisar moradores cadastrados';
  }

  _novoCadastro() {
    Modular.to.pushNamed('/familia').then(onGoBack);
  }

  // Atualizar ao voltar a essa tela
  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  late ScrollController _scrollController;
  bool lastStatus = true;
  double height = 200;

  void _scrollListener() {
    if (_isShrink != lastStatus) {
      setState(() {
        lastStatus = _isShrink;
      });
    }
  }

  bool get _isShrink {
    return _scrollController.hasClients &&
        _scrollController.offset > (height - kToolbarHeight);
  }

  /* METODOS DO SISTEMA */
  @override
  void initState() {
    initializeDateFormatting('pt_BR', null);
    _scrollController = ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: height,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              centerTitle: false,
              leading: _isShrink
                  ? IconButton(
                      icon: Image.asset('assets/icons/ic_launcher.png'),
                      onPressed: null,
                    )
                  : null,
              leadingWidth: 48,
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
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: [StretchMode.blurBackground],
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
                              angle: 4800,
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
                title: _appBarTitulo,
                titlePadding: EdgeInsets.only(left: 56, bottom: 16),
              ),
            ),
          ];
        },
        body: Scrollbar(
          isAlwaysShown: true,
          showTrackOnHover: true,
          child: ListView(
            padding: EdgeInsets.all(24.0),
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Card(
                      color: Colors.amber,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text('Cadastros Ativos\n'),
                            ValueListenableBuilder(
                                valueListenable: _totalFamilias,
                                builder: (BuildContext context, int value,
                                    Widget? child) {
                                  return Text(
                                    '$value',
                                    style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: SizedBox(
                      width: 16.0,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Card(
                      color: Colors.cyan,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text('Entregas Realizadas\n'),
                            ValueListenableBuilder(
                                valueListenable: _totalEntregas,
                                builder: (BuildContext context, int value,
                                    Widget? child) {
                                  return Text(
                                    '$value',
                                    style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 24.0,
              ),
              Text(
                'FAMÍLIAS ATENDIDAS',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 12.0,
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
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: data!.size,
                        itemBuilder: (context, index) {
                          Familia familia = data.docs[index].data();
                          // Lista
                          return ListTile(
                            horizontalTitleGap: 2,
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
                        });
                  }),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [_btnAdmin, _btnRelatorios, _btnNovoCadastro],
    );
  }
}
