import 'fam_dados.dart';
import 'fam_entregas.dart';
import 'fam_mapa.dart';
import 'fam_moradores.dart';
import '/models/familia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

late Familia familia;

class FamiliaPage extends StatefulWidget {
  const FamiliaPage({Key? key, required this.reference, this.editMode})
      : super(key: key);
  final DocumentReference<Familia> reference;
  final bool? editMode;

  get editionMode => editMode;

  @override
  _FamiliaPageState createState() => _FamiliaPageState();
}

class _FamiliaPageState extends State<FamiliaPage> {
  late bool editMode = widget.editionMode;

  Future<void> _loadFamilia(DocumentReference<Familia> reference) async {
    // Abre circulo de progresso
    //showDialog(
    //  context: context,
    //  builder: (BuildContext context) {
    //    return Center(child: CircularProgressIndicator());
    //  },
    //);
    //await reference.get().then((value) {
    //  print('chegou aqui');
    //Navigator.pop(context);
    //  if (value.exists) {
    //    familia = value.data()!;
    //  } else {
    //    familia = Familia.novaFamilia();
    //  }
    //setState(() {});

    DocumentSnapshot<Familia> snap = await reference.get();
    print('chegou aqui');
    if (snap.exists)
      familia = snap.data()!;
    else
      familia = Familia.novaFamilia();

    //});
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('pt_BR');
    _loadFamilia(widget.reference);
    print('depois aqui');
    //familia = Familia.novaFamilia();
    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
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
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      editMode = !editMode;
                      setState(() {});
                    },
                  ),
                  Icon(editMode ? Icons.save_rounded : Icons.edit_rounded),
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
              FamiliaDados(widget.reference, editMode),
              FamiliaMoradores(widget.reference),
              FamiliaEntregas(widget.reference),
              FamiliaMapa(widget.reference),
            ],
          ),
        ),
      ),
    );
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
