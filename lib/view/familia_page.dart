import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'fam_dados.dart';
import 'fam_entregas.dart';
import 'fam_moradores.dart';
import '/main.dart';
import '/models/familia.dart';
import '/models/morador.dart';

class FamiliaPage extends StatefulWidget {
  final String? referenceId;
  const FamiliaPage({Key? key, this.referenceId}) : super(key: key);

  @override
  _FamiliaPageState createState() => _FamiliaPageState();
}

class _FamiliaPageState extends State<FamiliaPage> {
  /* VARIAVEIS */
  late Familia mFamilia;
  late DocumentReference<Familia> mReference;
  late bool novoCadastro;

  /* WIDGETS */

  /* METODOS */

  /// Cria o registro para um novo cadastro
  Familia _novaFamilia() {
    return Familia(
        cadAtivo: true,
        cadDiacono: auth.currentUser!.uid,
        cadData: Timestamp.now(),
        cadSolicitante: '',
        cadEntregas: 0,
        famResponsavel: 0,
        famFoto: '',
        famTelefone1: 450,
        famTelefone2: 450,
        famRendaMedia: 0,
        famBeneficioGov: 0,
        endGeopoint: const GeoPoint(-25.5322523, -54.5864979),
        endCEP: 85852000,
        endLogradouro: '',
        endNumero: '',
        endBairro: '',
        endCidade: 'Foz do Iguaçu',
        endEstado: 'PR',
        endPais: 'Brasil',
        endReferencia: '',
        extraInfo: '',
        moradores: List<Morador>.empty(growable: true));
  }

  /// Resgata a referencia ao banco de dados
  DocumentReference<Familia> _getReference() {
    return FirebaseFirestore.instance
        .collection('familias')
        .doc(widget.referenceId)
        .withConverter(
            fromFirestore: (snapshot, _) => Familia.fromJson(snapshot.data()!),
            toFirestore: (document, _) => document.toJson());
  }

  /* METODOS DO SISTEMA */
  @override
  void initState() {
    initializeDateFormatting('pt_BR');
    novoCadastro = widget.referenceId?.isEmpty ?? true;
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
        mFamilia = snapshot.data?.data() ?? _novaFamilia();
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
                    mFamilia.moradores.isEmpty
                        ? 'Novo Cadastro'
                        : mFamilia.moradores[0].nome,
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
                FamiliaEntregas(refFamilia: mReference),
              ],
            ),
          ),
        );
      },
    );
  }
}
