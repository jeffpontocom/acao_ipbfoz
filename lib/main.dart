import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'models/diacono.dart';
import 'models/familia.dart';
import 'view/diacono_page.dart';
import 'view/familia_page.dart';
import 'view/login_page.dart';
import 'view/home_page.dart';

late DocumentReference<Familia> refFamilia;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPBFoz Ação Social',
      initialRoute: 'home',
      routes: {
        'home': (context) => HomePage(),
        'login': (context) => LoginPage(),
        'diacono': (context) => DiaconoPage(diacono: Diacono.instance),
        'familia': (context) => FamiliaPage(
              reference: refFamilia,
              editMode: true,
            ),
      },
    );
  }
}
