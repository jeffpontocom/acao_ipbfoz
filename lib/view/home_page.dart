import 'dart:async';

import 'package:acao_ipbfoz/data/diaconos.dart';
import 'package:acao_ipbfoz/models/morador.dart';
import 'package:flutter/foundation.dart';

import '/main.dart';
import '../models/familia.dart';
import '../ui/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

var _totalFamilias = new ValueNotifier(0);
var _totalEntregas = new ValueNotifier(0);

class TotalFamilias extends StatelessWidget {
  final ValueListenable<int> total;
  TotalFamilias(this.total);
  @override
  Widget build(BuildContext context) {
    return Text(
      total.value.toString(),
      style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
    );
  }
}

class TotalEntregas extends StatelessWidget {
  final ValueListenable<int> total;
  TotalEntregas(this.total);
  @override
  Widget build(BuildContext context) {
    return Text(
      total.value.toString(),
      style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;

  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  @override
  void initState() {
    if (auth.currentUser == null) Navigator.pop(context);
    loadDiaconos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'AÇÃO SOCIAL',
            ),
            Visibility(
              visible: true,
              child: Text(
                'Igreja Presbiteriana de Foz do Iguaçu',
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle_rounded),
            onPressed: () {
              Navigator.pushNamed(context, '/diacono').then(onGoBack);
            },
          ),
        ],
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(24.0),
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Card(
                    color: Colors.amber,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Cadastros Ativos\n'),
                          TotalFamilias(_totalFamilias),
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
                          TotalEntregas(_totalEntregas),
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
            Visibility(
              visible: _auth.currentUser != null ? true : false,
              child: OutlinedButton.icon(
                label: Text('Cadastrar nova família'),
                icon: Icon(Icons.add_business_sharp),
                style: mOutlinedButtonStyle,
                onPressed: () {
                  refFamilia = FirebaseFirestore.instance
                      .collection('familias')
                      .doc()
                      .withConverter(
                          fromFirestore: (snapshot, _) =>
                              Familia.fromJson(snapshot.data()!),
                          toFirestore: (document, _) => document.toJson());
                  Navigator.pushNamed(context, '/familia').then(onGoBack);
                },
              ),
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
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshots.data!.size == 0) {
                    return Center(
                      heightFactor: 5,
                      child: Text('Nenhum cadastro localizado!'),
                    );
                  }
                  final data = snapshots.data;
                  _totalFamilias.value = snapshots.data!.size;
                  _totalEntregas.value = 0;
                  data?.docs.forEach((element) {
                    _totalEntregas.value += element.data().cadEntregas;
                    element.reference
                        .collection('entregas')
                        .get()
                        .then((value) {
                      if (value.size > 0) {
                        element.reference.update({'cadEntregas': value.size});
                      } else {
                        element.reference.update({'cadEntregas': 0});
                      }
                    });
                  });
                  return Center(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: data!.size,
                        itemBuilder: (context, index) {
                          _totalFamilias.value = data.size;
                          Familia mFamilia = data.docs[index].data();
                          return ListTile(
                            horizontalTitleGap: 2,
                            isThreeLine: true,
                            leading: Icon(Icons.family_restroom_rounded),
                            // Nome do morador
                            title: Text(
                              mFamilia.moradores[mFamilia.famResponsavel].nome,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            // Bairro
                            subtitle: Text(_integrantes(mFamilia) +
                                '\n' +
                                mFamilia.endBairro +
                                ' • ' +
                                mFamilia.cadEntregas.toString() +
                                ' entregas realizadas.'),
                            onTap: () {
                              refFamilia = data.docs[index].reference;
                              Navigator.pushNamed(context, '/familia')
                                  .then(onGoBack);
                            },
                          );
                        }),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

String _integrantes(Familia mFamilia) {
  int criancas = 0;
  int adultos = 0;
  int idosos = 0;
  mFamilia.moradores.forEach((element) {
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
  if (criancas != 0 && adultos == 0 && idosos == 0) return '$criancas crianças';
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
