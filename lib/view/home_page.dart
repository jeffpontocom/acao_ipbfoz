import 'dart:async';

import 'package:flutter/scheduler.dart';

import '/main.dart';
import '/models/diacono.dart';
import '/models/familia.dart';
import '../ui/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

int _totalFamilias = 0;
int _totalEntregas = 0;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;

  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  void _loadUserAsDiacono(String uid) async {
    await FirebaseFirestore.instance
        .collection('diaconos')
        .doc(uid)
        .withConverter<Diacono>(
            fromFirestore: (snapshot, _) => Diacono.fromJson(snapshot.data()!),
            toFirestore: (pacote, _) => pacote.toJson())
        .get()
        .then((DocumentSnapshot<Diacono> documentSnapshot) {
      if (documentSnapshot.exists) {
        Diacono.instance.uid = documentSnapshot.id;
        Diacono.instance.email = documentSnapshot.data()!.email;
        Diacono.instance.nome = documentSnapshot.data()!.nome;
        Diacono.instance.telefone = documentSnapshot.data()!.telefone;
      } else {
        if (Diacono.instance.email.isEmpty) {
          Diacono.instance.uid = uid;
          Diacono.instance.email = _auth.currentUser!.email!;
        }
      }
    });
  }

  void _loadPerfil() {
    if (_auth.currentUser == null) {
      Navigator.pushNamed(context, '/login').then(onGoBack);
    } else {
      Navigator.pushNamed(context, '/diacono').then(onGoBack);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser != null) {
      _loadUserAsDiacono(_auth.currentUser!.uid);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('AÇÃO SOCIAL IPBFoz'),
        actions: <Widget>[
          TextButton(
            child: Text(
              _auth.currentUser == null ? 'ENTRAR' : 'MEU PERFIL',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              _loadPerfil();
            },
          ),
          Icon(_auth.currentUser == null
              ? Icons.account_circle_outlined
              : Icons.account_circle),
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
                          Text(
                            '$_totalFamilias',
                            style: TextStyle(
                                fontSize: 24.0, fontWeight: FontWeight.bold),
                          )
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
                          Text(
                            '$_totalEntregas',
                            style: TextStyle(
                                fontSize: 24.0, fontWeight: FontWeight.bold),
                          )
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
                  _refreshTotalFamilia(snapshots.data!.size);
                  final data = snapshots.data;
                  data?.docs.forEach((element) {
                    element.reference
                        .collection('entregas')
                        .get()
                        .then((value) {
                      if (value.size > 0) {
                        _refreshTotalEntregas(value.size);
                      }
                    });
                  });
                  return Center(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: data!.size,
                        itemBuilder: (context, index) {
                          int resp = data.docs[index].data().famResponsavel;
                          int totalEntregas = 0;
                          data.docs[index].reference
                              .collection('entregas')
                              .get()
                              .then((value) => totalEntregas = value.size);
                          return ListTile(
                            horizontalTitleGap: 2,
                            isThreeLine: true, trailing: Text('Abrir'),
                            leading: Icon(Icons.family_restroom_rounded),
                            // Nome do morador
                            title: Text(
                              data.docs[index].data().moradores[resp].nome,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            // Bairro
                            subtitle: Text(data.docs[index].data().endBairro +
                                '\n' +
                                totalEntregas.toString() +
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

  Future<void> _refreshTotalFamilia(int total) async {
    SchedulerBinding.instance!.addPostFrameCallback((_) => setState(() {
          _totalFamilias = total;
        }));
  }

  Future<void> _refreshTotalEntregas(int valor) async {
    SchedulerBinding.instance!.addPostFrameCallback((_) => setState(() {
          _totalEntregas = _totalEntregas + valor;
        }));
  }
}
