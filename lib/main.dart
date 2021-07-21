import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'models/diacono.dart';
import 'models/familia.dart';
import 'view/diacono_page.dart';
import 'view/familia_page.dart';
import 'view/home_page.dart';
import 'view/login_page.dart';

final auth = FirebaseAuth.instance;
late Diacono usuarioLogado;
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
      debugShowCheckedModeBanner: false,
      title: 'IPBFoz Ação Social',
      home: auth.currentUser != null ? HomePage() : LoginPage(),
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/diacono': (context) => DiaconoPage(diacono: usuarioLogado),
        '/familia': (context) => FamiliaPage(
              reference: refFamilia,
              editMode: true,
            ),
      },
    );
  }
}
