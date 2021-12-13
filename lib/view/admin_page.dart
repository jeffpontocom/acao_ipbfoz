//import 'dart:developer' as dev;

import 'package:acao_ipbfoz/models/familia.dart';
import 'package:acao_ipbfoz/utils/mensagens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '/app_data.dart';
import '/utils/util.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with TickerProviderStateMixin {
  /* VARIAVEIS */
  ScrollController _scrollController = ScrollController();

  /* METODOS */

  /* WIDGETS */
  Widget get appInfo {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'appname',
            child: Text(
              AppData.appName,
              style: const TextStyle(
                fontSize: 25,
                fontFamily: 'Pacifico',
              ),
            ),
          ),
          const Text(
            'Igreja Presbiteriana de Foz do Iguaçu',
          ),
          Text(
            'Versão ${AppData.version}',
            style: const TextStyle(color: Colors.grey),
          ),
          const Text(
            'Publicada em dezembro de 2021',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget tituloSecao(titulo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        titulo,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget get listaInativos {
    return StreamBuilder<QuerySnapshot<Familia>>(
      stream: FirebaseFirestore.instance
          .collection('familias')
          .where('cadAtivo', isEqualTo: false)
          .orderBy('cadData')
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
        return Scrollbar(
          isAlwaysShown: true,
          showTrackOnHover: true,
          controller: _scrollController,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true, // Obrigatorio (gera erro se falso)
            physics: const ScrollPhysics(), // Obrigatorio (nao move se nulo)
            padding:
                EdgeInsets.symmetric(horizontal: Util.paddingListH(context)),
            controller: _scrollController,
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
                subtitle: Text(familia.endBairro),
                //+ ' • ' +
                //familia.cadEntregas.toString() +
                //' entregas realizadas.'),
                onTap: () {
                  Modular.to.pushNamed('/familia?id=' +
                      snapshots.data!.docs[index].reference.id);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget get listaDiaconos {
    List<String> ids = AppData.diaconos.keys.toList();
    return Scrollbar(
      isAlwaysShown: true,
      showTrackOnHover: true,
      controller: _scrollController,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true, // Obrigatorio (gera erro se falso)
        itemCount: AppData.diaconos.length,
        controller: _scrollController,
        itemBuilder: (context, i) {
          return ListTile(
            leading: IconButton(
              icon: Hero(
                tag: ids[i],
                child: const Icon(Icons.account_circle),
              ),
              onPressed: null,
            ),
            title: Text(AppData.diaconos[ids[i]]?.nome ?? '[Erro]'),
            subtitle: Text(AppData.diaconos[ids[i]]?.email ?? '[Erro]'),
            trailing: const IconButton(
              icon: Icon(Icons.phone),
              onPressed: null,
            ),
            onTap: () {
              Modular.to.pushNamed('/diacono?id=' + ids[i]);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração do sistema'),
        titleSpacing: 0,
      ),
      body: Scrollbar(
        isAlwaysShown: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: Util.paddingListH(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              appInfo,
              const Divider(),
              tituloSecao('Gerenciar base de dados'),
              ListTile(
                leading: const Icon(Icons.groups),
                title: const Text('Relação de Diáconos'),
                subtitle: const Text('Consultar e/ou alterar dados de acesso'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                onTap: () {
                  Mensagem.bottomDialog(
                    context: context,
                    icon: Icons.groups,
                    titulo: 'Relação de diáconos',
                    conteudo: listaDiaconos,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.no_accounts),
                title: const Text('Cadastros inativos'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                subtitle: const Text(
                    'Consultar famílias que já foram atendidas pela Ação Social'),
                onTap: () {
                  Mensagem.bottomDialog(
                    context: context,
                    icon: Icons.no_accounts,
                    titulo: 'Cadastros inativos',
                    conteudo: listaInativos,
                  );
                },
              )
              //const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
