import 'dart:developer' as dev;
import 'package:acao_ipbfoz/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'models/diacono.dart';

class AppData {
  static const mLogClass = 'AppData';
  static late final String appName;
  static late final String packageName;
  static late final String version;
  static late final String buildNumber;
  static Diacono? usuario;
  static Map<String, Diacono> diaconos = new Map();

  /// Principais informações sobre o app
  AppData();

  Future loadPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = kIsWeb ? 'Ação Social' : 'Ação Social';
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    dev.log('Dados básicos do app carregados.', name: mLogClass);
  }

  Future loadDiaconos() async {
    await FirebaseFirestore.instance
        .collection('diaconos')
        .withConverter<Diacono>(
            fromFirestore: (snapshot, _) => Diacono.fromJson(snapshot.data()!),
            toFirestore: (diacono, _) => diacono.toJson())
        .get()
        .then(
      (QuerySnapshot<Diacono> querySnapshots) {
        if (querySnapshots.size > 0) {
          querySnapshots.docs.forEach((element) {
            diaconos.addAll({element.id: element.data()});
            if (auth.currentUser != null &&
                auth.currentUser!.uid == element.id) {
              usuario = element.data();
              usuario!.uid = element.id;
              dev.log('Dados do usuário logado carregado com sucesso!',
                  name: mLogClass);
            }
          });
          dev.log('Lista de diaconos carregada com sucesso!', name: mLogClass);
        }
      },
    );
  }
}
