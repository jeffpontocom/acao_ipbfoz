import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'fam_dados.dart';
import 'fam_entregas.dart';
import 'fam_moradores.dart';
import '/models/familia.dart';

class FamiliaPage extends StatefulWidget {
  final String? id;
  const FamiliaPage({Key? key, this.id}) : super(key: key);

  @override
  _FamiliaPageState createState() => _FamiliaPageState();
}

class _FamiliaPageState extends State<FamiliaPage> {
  /* VARIAVEIS */
  late Familia mFamilia;
  late DocumentReference<Familia> mReference;

  /* WIDGETS */

  /* METODOS */

  /// Resgata a referencia ao banco de dados
  DocumentReference<Familia> _getReference() {
    return FirebaseFirestore.instance
        .collection('familias')
        .doc(widget.id)
        .withConverter(
          fromFirestore: (snapshot, _) => Familia.fromJson(snapshot.data()!),
          toFirestore: (document, _) => document.toJson(),
        );
  }

  /* METODOS DO SISTEMA */
  @override
  void initState() {
    mReference = _getReference();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Familia>>(
      future: mReference.get(),
      builder: (context, snapshot) {
        // Enquanto carrega
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        // Se erro
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Erro!'),
            ),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "Algo errado!\nAparentemente você está sem conexão com a Internet.",
                ),
              ),
            ),
          );
        }
        // Preenche família
        mFamilia = snapshot.data?.data() ??
            Familia(
                cadAtivo: false,
                cadDiacono: '',
                cadData: Timestamp.now(),
                cadNomeFamilia: 'Erro',
                moradores: []);
        // Interface
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              titleSpacing: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Família', textScaleFactor: 0.6),
                  Text(
                    mFamilia.cadNomeFamilia,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              bottom: const TabBar(
                labelStyle: TextStyle(overflow: TextOverflow.ellipsis),
                tabs: [
                  Tab(text: "Cadastro"),
                  Tab(text: "Moradores"),
                  Tab(text: "Entregas"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                FamiliaDados(familia: mFamilia, reference: mReference),
                FamiliaMoradores(familia: mFamilia, reference: mReference),
                FamiliaEntregas(familia: mFamilia, refFamilia: mReference),
              ],
            ),
          ),
        );
      },
    );
  }
}
