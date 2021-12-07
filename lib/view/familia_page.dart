import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'fam_dados.dart';
import 'fam_entregas.dart';
import 'fam_mapa.dart';
import 'fam_moradores.dart';
import '/main.dart';
import '/models/familia.dart';
import '/models/morador.dart';
import '/ui/dialogs.dart';

late DocumentReference<Familia> reference;
late Familia familia;
//late bool editMode;
late bool onFirestore;

class FamiliaPage extends StatefulWidget {
  const FamiliaPage({Key? key, this.reference, this.editMode, this.referenceId})
      : super(key: key);
  final DocumentReference<Familia>? reference;
  final bool? editMode;
  final String? referenceId;

  @override
  _FamiliaPageState createState() => _FamiliaPageState();
}

class _FamiliaPageState extends State<FamiliaPage> {
  late bool editMode;

  /// Criar nova família
  DocumentReference<Familia> novaFamilia() {
    return FirebaseFirestore.instance
        .collection('familias')
        .doc(widget.referenceId)
        .withConverter(
            fromFirestore: (snapshot, _) => Familia.fromJson(snapshot.data()!),
            toFirestore: (document, _) => document.toJson());
  }

  @override
  void initState() {
    initializeDateFormatting('pt_BR');
    reference = widget.reference ?? novaFamilia();
    editMode = widget.editMode ?? false;
    reference.get().then((value) {
      if (value.exists) {
        familia = value.data()!;
        onFirestore = true;
        editMode = false;
      } else {
        editMode = true;
        familia = Familia(
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
        onFirestore = false;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Familia>>(
      future: reference.get(),
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
        // Se OK
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              titleSpacing: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Família', textScaleFactor: 0.6),
                  Text(
                    familia.moradores.isEmpty
                        ? 'Novo Cadastro'
                        : familia.moradores[0].nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton.icon(
                  label: Text(editMode ? 'SALVAR' : 'EDITAR'),
                  icon: Icon(
                      editMode ? Icons.save_rounded : Icons.mode_edit_rounded),
                  style: TextButton.styleFrom(primary: Colors.white),
                  onPressed: () {
                    if (editMode) {
                      _salvarDados();
                    } else {
                      setState(() {
                        editMode = !editMode;
                      });
                    }
                  },
                ),
              ],
              bottom: const TabBar(
                labelStyle: TextStyle(overflow: TextOverflow.ellipsis),
                tabs: [
                  Tab(text: "Cadastro"),
                  Tab(text: "Moradores"),
                  Tab(text: "Entregas"),
                  Tab(text: "Mapa"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                FamiliaDados(editMode: editMode),
                FamiliaMoradores(editMode: editMode),
                const FamiliaEntregas(),
                const FamiliaMapa(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _salvarDados() {
    if (familia.moradores.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Atenção'),
          content: Text('Ao menos um morador deve ser cadastrado.'),
        ),
      ).then((value) {
        return;
      });
    } else {
      showLoaderDialog(context);
      reference.set(familia).then((value) {
        Navigator.pop(context);
        editMode = !editMode;
        onFirestore = true;
        setState(() {});
      }).catchError((error) {
        dev.log('Falha ao adicionar: $error', name: 'FamiliaPage');
        Navigator.pop(context);
      });
    }
  }
}
