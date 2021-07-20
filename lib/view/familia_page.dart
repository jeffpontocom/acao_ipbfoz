import 'package:acao_ipbfoz/ui/dialogs.dart';

import 'fam_dados.dart';
import 'fam_entregas.dart';
import 'fam_mapa.dart';
import 'fam_moradores.dart';
import '/models/familia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

late DocumentReference<Familia> reference;
late Familia familia;
late bool editMode;

class FamiliaPage extends StatefulWidget {
  const FamiliaPage({Key? key, required this.reference, required this.editMode})
      : super(key: key);
  final DocumentReference<Familia> reference;
  final bool editMode;

  //get editionMode => editMode;

  @override
  _FamiliaPageState createState() => _FamiliaPageState();
}

class _FamiliaPageState extends State<FamiliaPage> {
  @override
  void initState() {
    initializeDateFormatting('pt_BR');
    reference = widget.reference;
    editMode = widget.editMode;
    reference.get().then((value) {
      if (value.exists) {
        familia = value.data()!;
      } else {
        familia = new Familia.novaFamilia();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Familia>>(
        future: reference.get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: Text('Erro!'),
              ),
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    "Algo errado!\nAparentemente você está sem conexão com a Internet.",
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: DefaultTabController(
              length: 4,
              child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      title: Text('Cadastro da família'),
                      expandedHeight: 220.0,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Image(
                          image: AssetImage('assets/images/sample_casa.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            editMode ? 'SALVAR' : 'EDITAR',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            if (editMode) {
                              showLoaderDialog(context);
                              reference.set(familia).then((value) {
                                Navigator.pop(context);
                                editMode = !editMode;
                                setState(() {});
                              }).catchError((error) {
                                print("Failed to add: $error");
                                Navigator.pop(context);
                              });
                            } else {
                              editMode = !editMode;
                              setState(() {});
                            }
                          },
                        ),
                        Icon(
                            editMode ? Icons.save_rounded : Icons.edit_rounded),
                      ],
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          labelColor: Colors.black87,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: "Cadastro"),
                            Tab(text: "Moradores"),
                            Tab(text: "Entregas"),
                            Tab(text: "Mapa"),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    FamiliaDados(),
                    FamiliaMoradores(),
                    FamiliaEntregas(),
                    FamiliaMapa(),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
